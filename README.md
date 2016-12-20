# Text2Dots
Tiny Windows application for converting chunks of text into its representation in Unicode Braille dots

Text2Dots can be easily compiled with AutoIt3 (I used the SciTE editor for that). It requires a `liblouis.dll` library, which is available from http://liblouis.org/downloads/, and should be placed in the same directory as the application.

It also requires Liblouis tables, which should be located in the `tables/` subdirectory of the application directory by default, but can be moved elsewhere if you adjust the path in `text2dots.ini` (this file is created/updated whenever the app exists). By default, English US Grade 2 table will be used, but that can be changed in the configuration file as well.

The Translate checkbox tells the application whether the string should be passed to `lou_translateString()` before converting it to dots. If this is unchecked, the text will be converted to Braille dots in its verbatim form, and if checked, Liblouis might apply contractions and other transformations to the text as necessary, before converting it.