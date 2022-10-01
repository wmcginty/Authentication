# Auth

## Introduction

This project demonstrates a simple implementation of various authentication processes including basic authentication, bearer authentication and Sign in with Apple. The front-end is written entirely in SwiftUI and demonstrates simplistic versions of the following features:

- Register with email / password
- Login with email / password
- Sign in (and sign up) with Apple
- Authentication status check
- Automatic refresh of access token when receiving a 401 Unauthorized back from the server

The application utilizes the Hyperspace library to simplify many of it's networking interactions and to provide the foundation for the 'automatic refresh of access tokens' feature. This application opts to refresh automatically when receiving a 401 Unauthorized response, but this behavior is entirely customizable. Note that the application currently disabled ATS and allows arbitrary loads to communicate with the local server - this should be disabled in a production environment.
 
The backend is also written entirely in Swift (using Vapor 4), and heavily utilizes `async` / `await`. It contains a "custom" implementation that backs all the features seen in the iOS application. A [Paw](https://paw.cloud/) document is available in the [repository](./Backend.paw) which will show an overview of the available APIs and their usage.


### Email / Password Authentication

For the basic register/login with email and password, the backend uses it's own `PostgreSQL` database to create and store `User`, `Access Token` and `Refresh Token` objects. The token objects are opaque tokens, and have parent relationships back to the relevant `User`. This enables tokens to be dispensed on login, refreshed with a refresh token and revoked if necessary. Although the backend provides an estimated time of expiry and the front-end will attempt to locally validate an access token before use, this estimate is not firm.


### Sign in with Apple

The backend contains a fully custom implementation of this feature, which is based on OpenID Connect and OAuth 2. Upon receiving an identity token ([JWT](https://jwt.io)) and an authorization code from the application after the client has utilized the `AuthenticationServices` framework to [authenticate a user with Apple](https://developer.apple.com/documentation/sign_in_with_apple/implementing_user_authentication_with_sign_in_with_apple) (additional context available [here](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/authenticating_users_with_sign_in_with_apple#3383773)), it is fully verified by the backend using the process described [here](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/verifying_a_user). The vast majority of the code involved in this process on the backend is in the `SocialUserRouteController`, including the full details of what is verified in the identity token. Once the identity token has been properly verified, a new account is created (if necessary) and a set of access and refresh tokens are generated and returned by the user.

In some cases, the authorization code returned by the framework will be used to make authenticated requests to Apple on the user's behalf. That process is described [here](https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens).


## Requirements

Requires iOS 16.0, macOS 12.0, Vapor 4, PostgreSQL 14, Xcode 14


## Installation

After cloning the project and opening the workspace, Swift Package Manager will automatically resolve the necessary dependencies. At this point, two schemes should be available. `Auth` is the front-end application and should be fairly straightforward to run. `RunBackend` is the backend Vapor server, and running this scheme will start the server (by default at `localhost:8080`).

Note that a PostgreSQL database with the name `auth` is required to run the server properly. The recommended way to install PostgreSQL is to use [Postgres.app](https://postgresapp.com) to install PostgreSQL 14. Note that by default, the `psql` process will not start automatically - it must be `initialized` and `started` from inside the application (though, there are settings to both automatically start the Postgres app and the `psql` process on login to simplify this process). Note, that if you also have `psql` installed through Homebrew, this will likely conflict as both process cannot use Port 5432 (the default PostgreSQL port) at the same time.

Once you have PostgreSQL up and running, it is recommended to use a database viewer application to verify the state of the database as the server is running ([Table Plus](https://tableplus.com/) and [Postico](https://eggerapps.at/postico/) are highly recommended).

Note that in the case of PostgreSQL, the method for accessing the local and remote storages can differ greatly. The project is currently only set up to run locally. Take a look at `configure.swift` for more information as to how it is configured in the development environment. 


## Port Unavailable Errors

It is not uncommon during development of a server application to get into a state where multiple processes are trying to use a port. For example, if Xcode shuts down the server improperly, it is likely it will fail to launch the next time because Port 8080 is in use. In addition, if Port 5432 is in use when the server is successfully launched, your database can not be connected which will also cause the server to crash.

In these cases, you may see something to this effect when launching the server locally in the Xcode console:

```
[ NOTICE ] Server starting on http://127.0.0.1:8080
[ WARNING ] bind(descriptor:ptr:bytes:): Address already in use (errno: 48)
Swift/ErrorType.swift:200: Fatal error: Error raised at top level: bind(descriptor:ptr:bytes:): Address already in use (errno: 48)
2022-02-24 19:56:04.885467-0600 Run[39965:2629342] Swift/ErrorType.swift:200: Fatal error: Error raised at top level: bind(descriptor:ptr:bytes:): Address already in use (errno: 48)
```

Instead of changing the ports each time this occurs, you can use the following series of commands to find and kill the offending processes, which should hopefully restore your ability to launch and utilize those ports.

```
lsof -i tcp:<port>
kill -9 <process id>
```


## Final Notes

This project is meant to be introductory and should not be used in production without thorough review for correctness. If you notice any problems, mistakes or bugs, contributions and bug reports are not only welcome but appreciated!
