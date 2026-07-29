[README.md](https://github.com/user-attachments/files/30519914/README.md)
# My Life App

A 3-tab Flutter app:
1. **Food Today** — log what you eat/order with cost, see daily total
2. **Work To Do** — add tasks, check off when done
3. **Semester Plans** — goals table for Sem 5, 6, 7, 8 with status tracking# My Life App

A 3-tab Flutter app:
1. **Food Today** — log what you eat/order with cost, see daily total
2. **Work To Do** — add tasks, check off when done
3. **Semester Plans** — goals table for Sem 5, 6, 7, 8 with status tracking

All data is saved on your device automatically (no internet needed to use the app).

## How to get the .apk (no local setup needed)

1. Create a **free GitHub account** if you don't have one: https://github.com/signup
2. Create a **new repository** (click the "+" top right → "New repository"). Name it anything, e.g. `my-life-app`. Keep it Public or Private, doesn't matter.
3. Upload **all the files in this folder** (including the hidden `.github` folder) to that repository:
   - Easiest way: on the repo page, click "uploading an existing file", then drag and drop everything, OR
   - Use GitHub Desktop / git command line if you're comfortable with it.
4. Once uploaded, go to the **"Actions"** tab of your repository on GitHub.
5. You'll see a workflow called **"Build APK"** running (or click "Run workflow" if it didn't start automatically).
6. Wait 3-5 minutes for it to finish (green checkmark).
7. Click on the finished run → scroll down to **"Artifacts"** → download **app-release-apk.zip**.
8. Unzip it — inside is `app-release.apk`.
9. Transfer that `.apk` to your Android phone (email it to yourself, Google Drive, USB, whatever) and tap it to install. You may need to allow "install from unknown sources" the first time — Android will prompt you.

That's it — no Android Studio, no command line, all done on GitHub's servers for free.

## Making changes later

If you want to add features later, just edit the `.dart` files in `lib/`, upload the changed files to the same GitHub repo, and the Action will automatically rebuild a new APK.


All data is saved on your device automatically (no internet needed to use the app).

## How to get the .apk (no local setup needed)

1. Create a **free GitHub account** if you don't have one: https://github.com/signup
2. Create a **new repository** (click the "+" top right → "New repository"). Name it anything, e.g. `my-life-app`. Keep it Public or Private, doesn't matter.
3. Upload **all the files in this folder** (including the hidden `.github` folder) to that repository:
   - Easiest way: on the repo page, click "uploading an existing file", then drag and drop everything, OR
   - Use GitHub Desktop / git command line if you're comfortable with it.
4. Once uploaded, go to the **"Actions"** tab of your repository on GitHub.
5. You'll see a workflow called **"Build APK"** running (or click "Run workflow" if it didn't start automatically).
6. Wait 3-5 minutes for it to finish (green checkmark).
7. Click on the finished run → scroll down to **"Artifacts"** → download **app-release-apk.zip**.
8. Unzip it — inside is `app-release.apk`.
9. Transfer that `.apk` to your Android phone (email it to yourself, Google Drive, USB, whatever) and tap it to install. You may need to allow "install from unknown sources" the first time — Android will prompt you.

That's it — no Android Studio, no command line, all done on GitHub's servers for free.

## Making changes later

If you want to add features later, just edit the `.dart` files in `lib/`, upload the changed files to the same GitHub repo, and the Action will automatically rebuild a new APK.
