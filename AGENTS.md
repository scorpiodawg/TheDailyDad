The Daily Dad is an app written in Flutter.

- There is a single main screen that displays 3 categories: news, jokes, and factoids. These
  categories show collapsed by default.
- Tapping on any of the categories opens up that category to reveal three bullets that are
  scrollable, and closes/collapses the other categories
- Tapping on "News" shows the top 3 most popular news items of the day as single sentences.
  For instance, one topic or news item could say "Boeing airliner crash in Timbuktu kills 224".
  News items should be unique.
- Tapping on "Jokes" shows 3 new dad jokes. Jokes should never be repeated.
- Tapping on "Factoids" shows 3 interesting factoids of general interest in a variety of topics
  including science, health, medicine, astronomy, etc. The topics must all be unique.
- The displayed items are relevant for and stay the same each day, and reset/update the next
  day

Technology notes:
- Use Flutter for mobile and ensure it works on Android and iPhone
- Use smooth, fluid animations for collapse and reveal of the categories
- Use a modern font for displaying the items
- Use a tab size of 4
