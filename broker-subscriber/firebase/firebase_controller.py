import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore, auth

from os import getenv

class FirebaseAdmin:
    def __init__(self):
        self.cred = credentials.Certificate(getenv("FIREBASE_CREDENTIALS"))
        firebase_admin.initialize_app(self.cred)
        self.db = firestore.client()

        self.anonymous_login()
    
    def anonymous_login(self):
        try:
            # Anonymous sign-in using Firebase Auth (create an anonymous user)
            user = auth.create_user()
            return user
        
        except Exception as err:
            print(f"Unexpected error during anonymous login: {err}")
            return None
    
    def insert_data(self, data:dict):
        return self.db.collection("conditions").add(data)