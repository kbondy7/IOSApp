import * as functions from 'firebase-functions';
const admin = require('firebase-admin');
admin.initializeApp();
export const onLocationUpdate = functions.database
.ref('/{Group}')
.onUpdate((change) => {
  let key = change.after.key;
  let locations: any[] = new Array();
  let names: string[] = new Array();
  let ref = admin.database().ref(key);
  ref.once('value').then((snap: any) => {
    snap.forEach((user: any) => {
      user.forEach((data: any) => {
        if(typeof data.val() == 'string')
        {
          let _out1 = names.push(data.val());

        }
        else{
          let _out2 = locations.push(data.val())

        }
      })

    })
    if(locations.length > 1){
      for(let i = 0; i < locations.length - 1; i++){
        let dist_f = 0
        for(let j = i + 1; j < locations.length; j++){
          let user1 = locations[i];
          let user2 = locations[j];


          let latMid = (user1[0]+user2[0])/2;
          let m_per_deg_lat = 111132.954 - 559.822 * Math.cos( 2.0 * latMid ) + 1.175 * Math.cos( 4.0 * latMid);
          let m_per_deg_lon = (3.14159265359/180 ) * 6367449 * Math.cos( latMid );

          let deltaLat = Math.abs(user1[0] - user2[0]);
          let deltaLon = Math.abs(user1[1] - user2[1]);

          dist_f = 3.28 * Math.sqrt(Math.pow(deltaLat * m_per_deg_lat,2) + Math.pow( deltaLon * m_per_deg_lon , 2));
          console.log(dist_f)


        }
        if(dist_f > 100){
          
        }
      }
    }
  })



  return 0
})
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
