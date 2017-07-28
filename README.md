# JobShop
Simple, smart background job broker with built-in REST API
Supports job queueing, job failure reporting, failure notification.

## Requirements
- redis-server (case of using RedisRepository)
- mysql (case of using MySQLRepository)
- node 6.x or higher 

## Setting up 
### Repository
repository means storage where job data stores. JobShop currently supports Redis, MySQL or In-memory repo. please keep in mind that DO NOT use in-memory repo for production type.


### Running JobShop
```
$ npm install -g gulp
$ npm install 
$ gulp compile-coffee
$ npm start
```

# REST API spec
TBD
