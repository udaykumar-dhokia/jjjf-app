# Custom Guidelines

## Architecture & NestJS Standard
- **Always build standard CRUD operations** (`GET`, `POST`, `PUT`, `DELETE`) within the Controller and Service for **every** new domain module created, regardless of whether only one specific endpoint is initially requested.


## Code Style
- **Always write docstring comments for backend functions** - explaining what the function does, what parameters it takes, and what it returns. It should be in the format of **JSDoc**.
- **Always write the tags for the swagger api in backend** - for the routes.
- **Always use DTO pattern for incoming and outgoing data in backend.**
-