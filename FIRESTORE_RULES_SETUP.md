# Firestore Security Rules Setup

## Problem
You're getting `PERMISSION_DENIED` errors when trying to create or access groups in Firestore.

## Solution
You need to update your Firestore security rules in the Firebase Console.

## Steps to Fix:

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Select your project

2. **Navigate to Firestore Database**
   - Click on "Firestore Database" in the left sidebar
   - Click on the "Rules" tab at the top

3. **Copy and Paste the Rules**
   - Copy the contents of `firestore.rules` file
   - Paste them into the Firebase Console rules editor
   - Click "Publish" to save

4. **What These Rules Do:**
   - ✅ Allow authenticated users to read any player document
   - ✅ Allow users to create/update only their own player document
   - ✅ Allow users to read/write only their own tasks
   - ✅ Allow authenticated users to read any group
   - ✅ Allow authenticated users to create groups
   - ✅ Allow only the creator to update/delete a group

## Alternative: Using Firebase CLI

If you have Firebase CLI installed, you can deploy the rules directly:

```bash
firebase deploy --only firestore:rules
```

Make sure you're logged in:
```bash
firebase login
```

And initialize Firebase in your project:
```bash
firebase init firestore
```

