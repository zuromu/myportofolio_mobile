# MyPortfolio Mobile

[![CI](https://github.com/zuromu/myportofolio_mobile/actions/workflows/main.yaml/badge.svg?branch=main)](https://github.com/zuromu/myportofolio_mobile/actions/workflows/main.yaml)

A Flutter mobile app for my personal portfolio, built for the Platform-Based Programming course at Universitas Indonesia. It is the mobile side of my portfolio website, and it lives in its own repository, separate from the Django project.

- Web version (Django): https://github.com/zuromu/PlatformBasedDevelopment

## What the app does

- Shows 3 info cards at the top with my NPM, my name and my class.
- Shows a menu of cards (View Projects, Add Project, View Experience, Add Experience, Logout, View Skills). Each card has its own icon and color.
- Loads my projects and experience from the Django REST API. Anyone can view the lists and open an entry to see all its fields.
- Adding a project or an experience needs a login. The app gets a token from Django and sends it with every POST.
- If the token is no longer valid (401), the app clears the session and asks me to log in again.
- A drawer with Home, View Projects, Add Project, View Experience, Add Experience and Login or Logout is on every screen.

## How to run it

The app needs my Django backend running: https://github.com/zuromu/PlatformBasedDevelopment

1. Start the backend with `python manage.py runserver` in the Django project.
2. Clone this repository and run `flutter pub get`.
3. Generate the JSON code for the models (the `*.g.dart` files are not in Git):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Run the app. The default API URL is `http://10.0.2.2:8000`, which is the computer's localhost as seen from the Android emulator. In Chrome, pass the URL yourself:
   ```bash
   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
   ```
5. Check the code with `dart format --output=none --set-exit-if-changed lib`, `flutter analyze` and `flutter test`.

Logging in needs a Django user. Adding an experience needs a superuser account.

## Project structure

- `lib/main.dart`: provides `ApiClient` and `AuthState` to every screen with `MultiProvider`.
- `lib/config.dart`: the API base URL, read from `--dart-define=API_BASE_URL`.
- `lib/models/`: `Project` and `Experience`, made with `@JsonSerializable`.
- `lib/services/api_client.dart`: all HTTP calls. Throws `ApiException` when the status is not 2xx.
- `lib/services/auth_state.dart`: keeps the login token in memory.
- `lib/screens/`: the home page, login, and the list, detail and form screens for projects and experience.
- `lib/widgets/`: the drawer, the home cards and `ensureLoggedIn()` in `auth_guard.dart`.
- `test/`: widget tests. `experience_form_test.dart` uses `MockClient`, so it runs without Django.

## Weekly progress

### Week 8 (Tutorial 08 and Assignment 7)

- Set up Flutter and created the project.
- Moved the home page out of `main.dart` into `menu.dart` and made it a `StatelessWidget`.
- Built `InfoCard` and `ItemCard`, and put my own NPM, name and class in the cards.
- Added a `color` field to `ItemHomepage` so every button has its own color without any if-else.
- Added a fourth card (View Skills) and a SnackBar that matches the card color.
- Fixed a bottom overflow by making the page scrollable.
- Replaced the default counter test with tests for my page.
- Worked with feature branches and conventional commits (`feat:`, `fix:`, `test:`, `docs:`).

### Week 9 (Tutorial 09 and Assignment 8)

- Added a drawer (`LeftDrawer`) with Home, Add Project and Add Experience.
- Built the Add Project form from Tutorial 09 with validation and a summary dialog.
- Moved the code into `lib/screens/` and `lib/widgets/`.
- For Assignment 8 I built an Add Experience form that follows the Experience model of my Django site (title, description, category, thumbnail URL, start date, end date).
- Added an Add Experience action card on the home screen and a drawer entry for it.
- Switched all imports to `package:material_ui/material_ui.dart` because my Flutter version is 3.47.

### Week 10 (Tutorial 10 and Assignment 9)

- Added token login to the Django backend (`TokenAuthentication`) and `django-cors-headers` so Chrome can call the API.
- Added JSON models with `json_serializable`, an `ApiClient` and an `AuthState`, shared with `provider`.
- Built list and detail screens for projects (Tutorial 10) and for experience (Assignment 9) with `FutureBuilder`, pull to refresh, and loading, error and empty states.
- The Add Project and Add Experience forms now need a login and send a real POST to Django. Errors show in a SnackBar.
- Removed the Start Date field from the experience form, because Django sets `started_at` itself when the entry is created.
- Added a GitHub Actions workflow with `very_good_workflows` and a release APK build. I pinned Flutter 3.47.9 after a newer Flutter version broke the APK build.
- Added widget tests for the experience form with `MockClient`.

### Assignment 7

1. **Widget tree and parent-child relationships:**
In Flutter everything on the screen is a widget, and widgets are placed inside other widgets, so the whole UI becomes a tree. In my app, `MaterialApp` is the root, then `Scaffold`, then a `Column` that holds a `Row` of `InfoCard`s and a `GridView` of `ItemCard`s. A parent decides things like the layout and the space its children get, and the children draw themselves inside that space. When something changes, Flutter rebuilds the affected part of the tree from the top down, which is why small widgets are easier to manage.

2. **Widgets used in this project and what they do:**
- `MaterialApp`: the root of the app, sets the title, theme and home page.
- `Scaffold`: the basic page layout with an app bar and a body.
- `AppBar`: the top bar with the title "MyPortfolio".
- `SingleChildScrollView`: makes the page scrollable so nothing overflows.
- `Padding`: adds space around its child.
- `Column` and `Row`: stack children vertically or horizontally.
- `SizedBox`: adds an empty gap between widgets.
- `Center`: centers its child.
- `Text`: shows text.
- `Icon`: shows an icon like a folder or a star.
- `Card`: the card look for `InfoCard`, with a small shadow.
- `Container`: gives a child a size and padding.
- `GridView.count`: shows the item cards in a grid with 3 columns.
- `Material` and `InkWell`: give `ItemCard` its color and rounded corners, and make it tappable with a ripple effect.
- `SnackBar`: the small message at the bottom after a button is pressed.
- `ScaffoldMessenger`: the widget that shows and hides SnackBars.
- `MediaQuery` and `Theme`: read the screen width and the app colors.
- `InfoCard`, `ItemCard` and `MyHomePage`: my own widgets.

3. **Purpose of `MaterialApp`:**
`MaterialApp` sets up the things the whole app needs, like the theme, the title, the first page (`home`) and navigation. It also gives widgets access to Material Design parts such as SnackBars, text styles and colors. It is usually the root widget because everything below it can then use the same theme and navigation without extra setup.

4. **`StatelessWidget` vs `StatefulWidget`:**
A `StatelessWidget` never changes after it is built. It only shows the data it was given, like my `InfoCard` or `MyHomePage`. A `StatefulWidget` has a `State` object that can change while the app runs, and it redraws with `setState()`. I should use `StatelessWidget` when the screen just displays fixed data, and `StatefulWidget` when something changes over time, like a counter, a form field, a checkbox or data loaded from the internet.

5. **`BuildContext`:**
`BuildContext` tells a widget where it is in the widget tree. Flutter passes it into every `build` method. It matters because widgets use it to look up things above them in the tree, like the theme or the nearest `Scaffold`. In my code, `Theme.of(context)` reads the theme colors, `MediaQuery.of(context)` reads the screen width, and `ScaffoldMessenger.of(context)` finds the messenger that shows the SnackBar.

6. **Hot reload vs hot restart:**
Hot reload puts the new code into the running app and rebuilds the widgets, and it keeps the current state. It is fast and good for UI changes like colors and text. Hot restart restarts the app from the start, so the state is reset. I cannot rely on hot reload when I change `main()`, global variables or `initState`, or when I add new dependencies or change native files. In those cases I have to hot restart, and sometimes stop the app and run it again (a full restart).

## AI Usage Disclosure

I used Claude to understand the concepts behind the reflective questions.
- **Prompt Strategy:** I asked 7 concept questions about the widget tree, Stateless vs Stateful widgets, BuildContext, MaterialApp, the RenderFlex overflow error, hot reload and the ItemHomepage color design.
- **Limitations & Manual Fixes:** I wrote the code, tests, README answers and commit messages myself and checked them with `flutter analyze` and `flutter test`.
- **AI Chat Log:** https://claude.ai/share/8f54c06e-5e82-4c59-b7be-6316179d06e1


### Assignment 8

1. **Explain the differences between `Navigator.push()`, `Navigator.pushReplacement()`, and `Navigator.pop()`. Which method opens the form from the action card? Explain how the Home option in the drawer takes the user back to the home screen.**
`Navigator.push()` adds a new route on top of the stack, so the old screen stays underneath and Back returns to it. `Navigator.pushReplacement()` replaces the top route with a new one, so there is no old screen to go back to. `Navigator.pop()` removes the top route and shows the one below it. The action card uses `Navigator.push()`, so the system Back button returns to the home screen. The Home option in the drawer calls `pushReplacement()` with `MyHomePage()`, so it swaps the current form for the home screen.

2. **How does the arrangement of `Scaffold`, `AppBar`, and `Drawer` keep the page structure consistent? Give one example of the portfolio theme colors being used on more than one page.**
Every page uses a `Scaffold` with an `AppBar`, a `drawer` and a `body`, so each page has the same structure. The same `LeftDrawer` widget is used on the home screen, the Add Project form and the Add Experience form, so I only wrote the menu once. The indigo theme color shows up on more than one page: the drawer header, the AppBar and Save button of both forms, and the home AppBar (which uses the primary color from the indigo seed).

3. **Why was this layout chosen for the form? Explain what the spacing and scrolling widgets do when screen space is limited.**
I used `Form` > `SingleChildScrollView` > `Column`, with a `Padding` of 8 around every field. The padding gives space between fields so the form is easy to read. The `Column` does not scroll by itself, so `SingleChildScrollView` lets the user scroll when the screen is small or the keyboard is open. That way the Save button is still reachable. The dialog content is also in a `SingleChildScrollView` so a long description does not overflow.

4. **What roles do `GlobalKey<FormState>`, `validator`, and `validate()` play when Save is pressed? Give one example of a value the form rejects and explain why choosing an input widget or keyboard type alone is insufficient.**
`GlobalKey<FormState>` is attached to the `Form`, so the Save button can reach the form state from outside the widgets. Each `validator` checks one field and returns an error message, or `null` if it is fine. When Save is pressed, `validate()` runs every validator, shows the error text next to the invalid fields, and returns `true` only if all pass. For example, the form rejects a title with only spaces, a thumbnail like `abc`, or an end date before the start date. Choosing an input widget or keyboard type is not enough. `TextInputType.url` only changes the keyboard, and the user can still paste anything. Also, a date picker cannot know that the end date must not come before the start date.

## AI Usage Disclosure

I used Claude to understand the concepts behind the Assignment 8 reflective questions.
- **Prompt Strategy:** I asked 6 concept questions about the Navigator stack (push, pushReplacement and pop), why a form needs a `StatefulWidget` and a `GlobalKey<FormState>`, what `validate()` does and why a `validator` returns `null` for valid input, why a `Column` overflows on small screens and how `SingleChildScrollView` fixes it, how `showDatePicker()` works with `async` and `await`, and what the `drawer` property does and why one `LeftDrawer` is reused on every page.
- **Limitations & Manual Fixes:** I wrote the code, tests and README answers myself, and I checked the code with `flutter analyze` and `flutter test`.
- **AI Chat Log:** https://claude.ai/share/9b67aa38-c8c8-4b36-bb2f-7e477df9d813


### Assignment 9

1. **Why `@JsonSerializable(fieldRename: FieldRename.snake)` and `@JsonKey(includeToJson: false)` instead of raw maps?**
With a raw `Map<String, dynamic>`, every widget has to type the JSON keys by hand, and a typo or a wrong type only shows up when the app runs. The generated code does the conversion in one place, and `fieldRename: FieldRename.snake` turns `endedAt` into `ended_at` so the Dart names stay camelCase while Django gets snake_case. `includeToJson: false` keeps fields the server owns, like `id` and `started_at`, out of the POST body. One bug this prevents in my Experience model: if I had written the map by hand with `"endedAt"`, Django would ignore the unknown key and save every experience as ongoing without any error. Another one is `thumbnail`, which Django sends as `null` when it is empty. `@JsonKey(defaultValue: '')` turns that into an empty string, so the detail screen does not crash on a null value.

2. **Why initialize the `Future` in `initState()`, and why throw `ApiException` instead of returning `null`?**
`build()` can run many times, for example after `setState()`, when the keyboard opens or when the theme changes. If the `Future` were created inside `build()`, every rebuild would send a new GET request and the `FutureBuilder` would go back to the loading spinner. `initState()` runs only once, so the request is sent once and the Retry button and pull to refresh decide when to load again. Throwing `ApiException` makes a failed request a real error. `FutureBuilder` then gets `hasError` and shows the error state with Retry, and the form can check the status code to tell a 401 (log in again) from a 403 (not allowed). If `ApiClient` returned `null`, a server error would look the same as an empty list, and the user would see "No experience found." instead of an error.

3. **`SessionAuthentication` vs `TokenAuthentication`, and why keep both?**
`SessionAuthentication` uses the session cookie the browser gets after logging in, plus a CSRF token for POST requests. That works well in a browser, which stores and sends cookies by itself. A Flutter app does not keep cookies like a browser does, so `TokenAuthentication` is simpler: the app gets a token once from `/api/v1/auth/token/` and sends `Authorization: Token <key>` in the header of every write request. The backend keeps `SessionAuthentication` enabled so my Django website, the admin and the browsable API still work with a normal login. In my settings `TokenAuthentication` comes first, so a guest or a deleted token gets `401` instead of `403`, and that is the status the app uses to clear the session and ask for a login again.

4. **The `build` and `build_apk` jobs, and why `*.g.dart` is gitignored.**
The `build` job uses the reusable `flutter_package` workflow from `very_good_workflows`. It installs Flutter 3.47.9, runs `flutter pub get`, runs my setup command (`build_runner`), then checks formatting with `dart format --set-exit-if-changed`, runs `flutter analyze`, and runs `flutter test` with coverage. If any of these fail, the job fails. The `build_apk` job only starts after `build` passes (`needs: build`). It generates the code again, runs `flutter build apk --release`, and uploads the APK as the `app-release-apk` artifact. The `*.g.dart` files are ignored because they are generated from the model classes. Committing them would mean extra files in every diff, merge conflicts, and the risk of an old generated file not matching the model. CI does not need them in Git because both jobs run `build_runner` first and make them fresh.

## AI Usage Disclosure

I used Claude to help me understand concepts while doing this assignment.
- **Prompt Strategy:** I asked 7 concept questions about json_serializable (`FieldRename.snake` and `includeToJson: false`), creating the FutureBuilder Future in `initState()`, DRF SessionAuthentication vs TokenAuthentication, why Flutter web needs `django-cors-headers`, handling 401 vs 403, testing API calls with `MockClient`, and what the `very_good_workflows` flutter_package workflow checks along with why `*.g.dart` files are gitignored.
- **Limitations & Manual Fixes:** I wrote the code, tests, README answers and commit messages myself and checked them with `flutter analyze` and `flutter test`.
- **AI Chat Log:** https://claude.ai/share/237fb3f9-a639-4034-abdb-500c232f251d