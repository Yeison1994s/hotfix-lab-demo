class UserManager:
    def process_users(self, user_list):
        print("Processing users...")

        for u in user_list:
            # ❌ Bug: 'username' no existe, debería ser 'name'
            print(f"User: {u['username']} - Age: {u['age']}")

        print("All users processed successfully.")
