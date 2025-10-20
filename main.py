from users import UserManager

def main():
    print("=== Starting user data processor ===")

    manager = UserManager()
    # Carga de usuarios simulada
    users = [
        {"name": "Ruanet", "age": 21},
        {"name": "Carlos", "age": 29},
        {"name": "Mario", "age": 35}
    ]

    # Procesamiento (error dentro de la clase)
    manager.process_users(users)

    print("=== Process finished successfully ===")

if __name__ == "__main__":
    main()
