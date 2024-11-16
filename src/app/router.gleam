import app/web
import gleam/http.{Get, Post}
import gleam/list
import gleam/result
import gleam/string_builder
import wisp.{type Request, type Response}
/// The HTTP Request Handler (The application!)
///
pub fn handle_request(req: Request) -> Response {
  // Middleware
  use req <- web.middleware(req)

  // Routes
  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home(req)

    // This matches `/meals`.
    ["meals"] -> meals(req)

    // This matches `/meals/:id`.
    ["meals", id] -> show_meal(req, id)

    // This matches all other paths.
    //
    _ -> wisp.not_found()
  }
}

fn home(req: Request) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, Get)

  let html =
    string_builder.from_string(
      "<html>
        <head>
          <script src='https://unpkg.com/htmx.org@2.0.3'></script>
        </head>
        <body hx-boost='true'>
          <h1>Hello, Joe!</h1>

        </body>
      </html",
    )
  wisp.ok()
  |> wisp.html_body(html)
}

fn show_nav() -> Response {
  let html =
    string_builder.from_string(
      "
      <div>
        <a href='/'>Home</a>
        <a href='/meals'>Meals</a>
        <a href='/ingredients'>Ingredients</a>
        <a href='/shopping-list'>Shopping List</a>
        <div>
          <input name='meal-id'></input>
          <button
            hx-include='previous'
            hx-confirm='Are you sure?'
            hx-post='/meals'
            hx-target='body'
          >
            Go To Meal
          </button>
        </div>
      </div>
      ",
    )
  wisp.ok()
  |> wisp.html_body(html)
}

fn meals(req: Request) -> Response {
  // This handler for `/comments` can respond to both GET and POST requests,
  // so we pattern match on the method here.
  case req.method {
    Get -> list_meals(req)
    Post -> create_meal(req)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn list_meals(req: Request) -> Response {
  // In a later example we'll show how to read from a database.
  case wisp.get_query(req) {
    [] -> list_all_meals()
    [query, ..] -> list_some_meals(query)
  }
}

fn list_all_meals() -> Response {
  let html = string_builder.from_string("Created")
    wisp.ok()
    |> wisp.html_body(html)
}

fn list_some_meals(query: List(#(String, String))) -> Response {
  let html = {
    string_builder.from_strings(query)
  }
  wisp.ok()
  |> wisp.html_body(html)
}

fn create_meal(_req: Request) -> Response {
  // In a later example we'll show how to parse data from the request body.
  let html = string_builder.from_string("Created")
  wisp.created()
  |> wisp.html_body(html)
}

fn show_meal(req: Request, id: String) -> Response {
  use <- wisp.require_method(req, Get)

  // The `id` path parameter has been passed to this function, so we could use
  // it to look up a comment in a database.
  // For now we'll just include in the response body.
  let html = string_builder.from_string("Meal with id " <> id)
  wisp.ok()
  |> wisp.html_body(html)
}
