import { Elm } from './Main.elm'
import { initializeApp } from 'firebase/app'
import {
  getAuth,
  signInWithPopup,
  onAuthStateChanged,
  GoogleAuthProvider,
} from 'firebase/auth'

initializeApp({
  apiKey: process.env.ELM_APP_API_KEY,
  authDomain: process.env.ELM_APP_AUTH_DOMAIN,
  projectId: process.env.ELM_APP_PROJECT_ID,
})

const auth = getAuth()
const app = Elm.Main.init({
  node: document.getElementById('app'),
  flags: [
    process.env.ELM_APP_API_KEY,
    process.env.ELM_APP_PROJECT_ID,
    [window.innerHeight, window.innerWidth],
  ],
})

app.ports.signIn.subscribe(async () =>
  signInWithPopup(auth, new GoogleAuthProvider())
    .then(({ user: { email, uid } }) =>
      app.ports.signInInfo.send({ email, uid }),
    )
    .catch(app.ports.signInError.send),
)

app.ports.signOut.subscribe(async () => auth.signOut())

onAuthStateChanged(
  auth,
  user =>
    user && app.ports.signInInfo.send({ email: user.email, uid: user.uid }),
)
