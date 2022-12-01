# test_screenshot

A sample project to capture image from widget for flutter web html.   
In general `boundary?.toImage()` doesn't work on flutter web html version. So we have use a JS library [html2canvas](https://html2canvas.hertzen.com/) to take snapshot of widget.

## Getting Started

**To run the project**

    flutter run -d Chrome

**To run the project as HTML**


      flutter run --web-renderer html -d Chrome

** Image**

<img src="https://github.com/shofizone/widget_to_image_flutter_web_html/blob/master/Screenshot%202022-12-01%20at%208.52.13%20AM.png?raw=true" alt="drawing" width="300"/>


**Known Issue**
1. html2canvas take screenshot from the given area. So if something floats on top the area then it will be captured.
2. Some style properties are not supported eg. Color Filter. [more details](https://html2canvas.hertzen.com/features)
3. Custom ClipPath is getting ignored scene flutter 3.0