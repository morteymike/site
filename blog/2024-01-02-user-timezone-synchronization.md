# User Timezone Synchronization with Next JS and Django
Today, I built a system to store a user's timezone using Next JS and Django, so you don't have to. Let's get into it!

## Assumptions
I'm assuming you have a functional Next JS and Django app, and your users are able to authenticate with your backend. I'll also assume you have a minimal API set up.

## Client (Next JS)
First, let's get the user's current datetime and timezone from their browser.

We'll use the [Intl.DateTimeFormat](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DateTimeFormat) object to get the user's current timezone. We'll also use the [Dayjs](https://day.js.org/) library to get the user's current datetime.

Here's a simple function to get the user's current datetime and timezone:
```js
const getCurrentDatetimeHeader = () => {
  const now = dayjs();
  const clientTimeStr = now.format();
  const clientTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;

  return {
    'x-client-current-datetime': clientTimeStr,
    'x-client-timezone': clientTimezone,
  };
};
```

Next, we'll set these headers on every request to our backend. I'm using `Axios`. Be sure to call this function on client side before making any requests to your backend:
```js
import Axios from 'axios';

export function configureAxios() {
  Axios.defaults.baseURL = getApiUrl();
  if (headers) {
    Axios.defaults.headers.common = {
      ...Axios.defaults.headers.common,
      ...headers,
    };
  }
  const axios = Axios.create();

  return Axios;
}
```


## Backend (Django)
Next, we'll work to parse these headers and make sure our user's timezone is always up to date.

### Models
In order to store the user's timezone, we'll need to add a field to our `User` model. I have a custom `User` model subclassing `AbstractUser`, but you can add a `timezone` field to the user's profile model if you don't want to subclass `AbstractUser`.

```py
import pytz

class User(AbstractUser):
    ...
    TIMEZONES = tuple(zip(pytz.all_timezones, pytz.all_timezones))
    timezone = models.CharField(
        max_length=100,
        choices=TIMEZONES,
        default='UTC',
    )
    ...

    def update_timezone(self, timezone):
        """Function to update user timezone"""
        if self.timezone != timezone:
            self.timezone = timezone
            self.save(
                update_fields=[
                    'timezone',
                ]
            )
```

### Middleware
Next, let's create a Dango middleware to activate the user's timezone for each request.

This allows methods like django's `TruncDate` to use the user's timezone when making queries and aggregations. This is extremely useful if you need to aggregate objects by date, localized to the user's timezone.

Here's the middleware:
```py
import pytz
from django.utils import timezone


class TimezoneMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # tzname = "America/Chicago"

        tzname = None

        user = request.user
        if not user.is_anonymous and user.timezone:
            tzname = user.timezone

        if tzname:
            timezone.activate(pytz.timezone(tzname))
        else:
            timezone.deactivate()
        return self.get_response(request)
```

Be sure to add this middleware to your `MIDDLEWARE` setting in `settings.py`:
```py
MIDDLEWARE = [
    ...
    'path.to.TimezoneMiddleware',
    ...
]
```


### Updating User Timezone
Now that we have a middleware to activate the user's timezone, we can keep the user's timezone up to date via one of the following options:
1. Create another middleware to grab `X_CLIENT_TIMEZONE` and update the user's timezone if it's different from the current timezone.
2. In one of your existing API endpoints, check if `X_CLIENT_TIMEZONE` is different from the user's timezone, and update the user's timezone if it's different. This endpoint should be called frequently, so that the user's timezone is always up to date. 

I chose option 2. Here's a basic implementation:
```py
class CurrentUser(APIView):

    def get(self, request, format=None, *args, **kwargs):
            self.user.update_timezone(self.user_current_timezone)            
            ... # rest of view
```

Remember to hook this view up to your urls!


## Summary
And that's it! We've successfully:
1. Added the browser's timezone and current datetime to every request to our backend.
2. Intercepted the request in our backend and activated the user's timezone.
3. Updated the user's timezone automagically any time it's different from the browser's timezone.


## Next Steps
Now that we have the user's timezone, we can use it to localize datetimes and dates. This is extremely useful if you need to aggregate objects by date, localized to the user's timezone.

Now that your app can synchronize to a user's timezone, you can start building features that are localized to the user's timezone.


