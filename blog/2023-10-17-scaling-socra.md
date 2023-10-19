# Scaling socra's Infrastructure
This post focuses on some of the infrastructure powering [socra AI](https://socra.com). If you're a web developer looking to scale your application for the first time, this post is for you.

For most modern web apps looking to scale, manually deploying files to an nginx or Apache web server is not sufficient. Just because you can find many tutorials on how to do this online, doesn't mean it's the best, newest, or most efficient way to do it.

This is a common issue when learning to become a developer - you don't know the latest, greatest tools, so you may not know what to search for.

## The Basics
Let's assume your web app requires a database, backend, frontend, an asynchronous task queue for your backend, caching, and a method to route traffic to your services. This is a pretty standard requirement for most web apps.

## Infrastructure
At a high level, each service you create will be containerized and deployed to a Kubernetes cluster.

Kubernetes will help us load balance traffic across your services, and scale them up and down as needed. Kubernetes can also help us with rolling deployments, which will allow us to eliminate downtime during app upgrades.

For your database, we'll use a managed relational database service that can scale up and down to meet demand instantly.

More on these topics below.

### Database
Every robust application starts with a good backend, and a good backend starts with a good database. For most web apps, a relational database is your best choice. Relational databases are great for storing structured data, and they're easy to query.

If you're thinking you need a graph database for your use-case, there's a great chance you're wrong, and a relational database will work just fine. Except in rare cases, a strong relational database is your best friend. My preference is Postgres.

As for the database service, you have two options: self-hosted or managed. Self-hosted means you'll need to set up and maintain your own database server. This is a lot of work, and it's not worth it. Managed means you'll use a service like AWS RDS or AWS Aurora Serverless.

With that said, my preference is AWS Aurora Serverless V2 for Postgres. It can scale to any workload you may have, with read replicas across the globe. It's optimal for scale.

P.S. Don't make the mistake of self-hosting, and then having to worry about switching to a managed service later. It's a lot of work, and the cost of a managed service is negligible compared to the cost of your time (not to mention the downtime with your application).

### Backend
For your backend, you have quite a few options and flexibility.

At a high level, your backend *must* be extensible, well-supported, well-used, and *very* well documented. This essentially means you need to pick a "tried and true" backend - if your web app scales and you need to hire a backend developer to help you out, you don't want to be stuck with a backend that's not well supported or documented.

There's a great argument for using a javascript-based backend like Node JS, but I'm not going to make it here. I'm going to recommend a python-based backend, because it's what I know best. Frankly, I think JS has five or ten too many quirks to be a good choice for a backend, but that's just my opinion.

For my backend, my preference is [django](https://www.djangoproject.com/), with [Django REST Framework](https://www.django-rest-framework.org/). Django is a python-based web framework that's been around for some time, the documentation is excellent, and it's used *everywhere*.

One of my favorite parts of django is the Object Relational Mapper (ORM for short). The ORM allows you to interact with the database without writing **any** SQL. That's right, ZERO SQL. It's one less language you'll need to learn, except in very, very rare cases.

#### Distributed Task Queue + Scheduler
Your backend will need a distributed task queue and a scheduler for periodic tasks.

Why?

There are two main reasons:
1. You'll likely have HTTP requests that can trigger a long-running task. You don't want to block the HTTP request while the task is running, so you'll need to queue the task and return a response to the user. The task queue will handle the task asynchronously.
2. You'll likely have periodic tasks that need to run on a schedule. For example, you may need to send a daily email to your users, or run some scripts on some interval. The scheduler will help make this process much easier than cron.

For your task queue, I recommend [celery](https://docs.celeryproject.org/en/stable/), which plays well with django. For your scheduler, I recommend [celery beat](https://docs.celeryproject.org/en/stable/userguide/periodic-tasks.html).

Finally, your task queue and scheduler will need a backend to store their state. For this, I recommend [redis](https://redis.io/). Redis can also be used with Django Channels, which supports websockets (double whammy, yay!)

### Frontend
Similar to your backend, you'll want to pick a well-supported framework for your frontend.

[React](https://reactjs.org/) is by far the most popular frontend library today, and it'll be around for some time. It's a great choice.

With that said, `React` really is just a javascript library. For a robust frontend, you'll need a great frontend framework that can also render server-side. This is where [Next JS](https://nextjs.org/) comes in. Next JS is a framework built on top of React, and it's great for SEO and performance.

### Data-fetching
Your frontend will need to fetch data from your backend API. Here are my recommendations:
- [axios](https://axios-http.com/) for basic HTTP requests
- [swr](https://swr.vercel.app/) for data fetching and caching. SWR works great with Next JS, React, and axios. React Query is another great option.
- [axios-hooks](https://github.com/simoneb/axios-hooks) for other types of react hook-based queries

Combined together, you can create a robust data-fetching layer for your frontend.

### Javascript Monorepo
I recommend using a monorepo structure for your Next JS app, and all packages you build alongside your frontend. For this, I recommend [turborepo](https://turbo.build/).

`turborepo` has quite a few great examples to help get you started, so I won't go into too much detail here.

## Containerization
Ok, you've got your database, backend, and frontend up and running in development. Now what? Do you deploy each service individually on its own linux server, managing the entire configuration yourself? No, no, no...

You'll want to containerize each service, so that you can easily deploy them to a Kubernetes cluster. For this, I (and everyone else in the world) recommend [Docker](https://www.docker.com/).

Each of your services will require a `Dockerfile` to build the container image. You'll also need a `docker-compose.yml` file to run your services locally (if you want to, but I've never found it necessary).

## CI/CD
Ok, you've now got your services working locally and able to be built into containers locally. Now what? This is where automation comes in.

Continuous Integration (CI) and Continuous Deployment (CD) allow you to automate the process of testing, building, and deploying your services. CI/CD will become your best and worst friend, depending on the day.

For CI/CD, I recommend [Github Actions](https://github.com/features/actions). It's cheap and hosted on the same platform as your code, so it's easy to get started.

Basic CI/CD will allow you to make sure your code is working correctly on every push. This is a must-have!

As you get more advanced, you'll be able to do more interesting things with CI/CD, like:
- Build and publish container images on every push
- Deploy your services to a staging environment on every push
- Automatically deploy to production on each new release


## Container Orchestration
Now that we've got our services containerized, and CI/CD set up to help us automate builds and deployments, we'll use Kubernetes to orchestrate our containers.

Kubernetes is a container orchestration tool that allows us to deploy our containers to a cluster of servers, and manage them as a single unit. Kubernetes will help us with:
- Scaling our services up and down as needed
- Load balancing traffic across our services
- Rolling deployments to eliminate downtime during upgrades
- And much more...

My recommendation for Kubernetes is to locate your cluster geographically in close proximity to your database (preferably in the same datacenter, within the same internal network if possible). You'll gain some huge speed advantages by doing this.

Given our database of choice was with AWS, I'll recommend AWS Elastic Kubernetes Service (EKS). EKS is a managed Kubernetes service that allows you to deploy and manage your Kubernetes cluster.

***Note:***: AWS is not for the faint-of-heart. It will take some time to learn, and their documentation is generally thorough but unhelpful. You'll need to be patient and persistent to the your services deployed initially.

### Updating Container Images
Once you've got a cluster deployed and configured, you need to figure out how to update your container images. This is where CI/CD comes in.

When you push a new commit to your repository, you'll want to build and publish a new container image. Once pushed, you can automagically update your Kubernetes cluster with the newest images.

***Note:*** Kubernetes won't deploy a new image unless the image tag changes. This is a good thing, but it means you need to update the image tag in your kubernetes deployment file. We can set up a github action to do this for us.


## Automatic Deployment Across Environments
In order to manage multiple kubernetes clusters or environements, we'll need just one more service sitting on top of our kubernetes clusters. This service is called [helm](https://helm.sh/).

Helm allows you to dynamically change variables in your kubernetes deployment files, and deploy them to multiple environments. This is a must-have for any web app that needs to scale.

## Monitoring
Now that you've got your services deployed, you'll want to make sure that monitoring tools are your best friend. You'll want to know when your services are down, and you'll want to know why.

Here are some of my favorite tools for monitoring:
- [Sentry](https://sentry.io/) for error/bug tracking (frontend and backend). Sentry provides a great dashboard for tracking errors, and it integrates with most popular frameworks.
- [Prometheus](https://prometheus.io/) for monitoring your kubernetes cluster. Prometheus is a great tool for monitoring your cluster, and it integrates with Grafana.
- [Grafana](https://grafana.com/) for visualizing your Prometheus metrics. Grafana is a great tool for visualizing your metrics, and it integrates with Prometheus.
- AWS Dashboards for monitoring AWS services (database, cluster nodes). AWS provides great high-level metrics on database utilization, so you'll want to keep it bookmarked.

## Object Storage
If you're building a complex web application, you'll likely need a way to store and retrieve bigger files and media. This should **not** be stored in your database.

Instead, use object storage. My preference is AWS S3.