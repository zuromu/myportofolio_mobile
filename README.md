# MyPortfolio Mobile

A Flutter mobile app for my personal portfolio, built for the Platform-Based Programming course at Universitas Indonesia. It is the mobile side of my portfolio website, and it lives in its own repository, separate from the Django project.

## What the app does

- Shows 3 info cards at the top with my NPM, my name and my class.
- Shows a menu of cards (View Projects, Add Project, Logout, View Skills). Each card has its own icon and color.
- Pressing a card shows a SnackBar that says "You pressed the [Button Name] button!", in the same color as the card.

## How to run it

1. Install the Flutter SDK and set up an emulator or a browser target.
2. Clone this repository.
3. Run `flutter pub get`.
4. Run `flutter run`.
5. Run `flutter analyze` and `flutter test` to check the code.

## Project structure

- `lib/main.dart`: starts the app and sets up `MaterialApp` with the theme.
- `lib/menu.dart`: the home page (`MyHomePage`), plus `InfoCard`, `ItemHomepage` and `ItemCard`.
- `test/widget_test.dart`: widget tests for the home page.

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
