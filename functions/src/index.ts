import * as functions from 'firebase-functions';

export const onLocationUpdate = functions.database
.ref('/{Group}/{UserID}')
.onUpdate((change) => {
  const after = change.after.val()
  console.log(after.coords)
  return 0
})
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
