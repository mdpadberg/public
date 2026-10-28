# Screenshots

The images in this folder are screenshots of `../professor-assistant-library.html`.

## 📐 Size
| Slide type | Viewport (width × height) |
| :--- | :--- |
| Normal slide (`== Title`) | 1549 × 699 pixels |
| `centered-slide` | 1521 × 800 pixels |

*   **Device pixel ratio (DPR):** 2, for a sharp image

These sizes fill the slide. Don't make the image narrower: on a normal slide it moves to the next slide, and on a `centered-slide` it runs past the edges.

## 🛠️ How to make a screenshot
1. Open `professor-assistant-library.html` in the browser.
2. Press `F12` to open the developer tools.
3. Turn on responsive design mode (`Ctrl+Shift+M`).
4. Set the viewport to the size from the table.
5. Set the DPR to **2**.
6. Take the screenshot:
   * **Firefox:** click the camera icon in the responsive design toolbar.
   * **Chrome:** open the command menu (`Ctrl+Shift+P`) and run *Capture screenshot*.
7. Save it in this folder as `<name>.png`, e.g. `student.png`.

## 🖼️ Slide code
Normal slide:
```typst
== Student
#align(center + horizon)[
  #image("./images/student.png")
]
```

`centered-slide`:
```typst
#centered-slide[
  #image("./images/student.png")
]
```

## 💡 Tips
* Keep the page content centred and avoid wide empty borders. Empty space in the screenshot makes the content look small on the slide.
