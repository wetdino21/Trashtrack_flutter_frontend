# Setup trashtrack Guidelines (Mobile)

-----------------------------------------------
Setup Database
  Download & Install PostgreSQL
     - Go to the official site: https://www.postgresql.org/download/windows
     - Click "Download the Installer" → Choose the latest version.
     - Run the installer and follow these steps:
     - Select Components: Install PostgreSQL Server, pgAdmin, and Command Line Tools.
     - Set Password: Choose a strong password for the PostgreSQL superuser (postgres).
     - Port: Default is 5432 (leave it as is).

  Create an Empty Database
     - Open pgAdmin or psql CLI.
     - Run this SQL command to create a new database: CREATE DATABASE trashtrack;

  Navigate to PostgreSQL bin Directory
     - Open Command Prompt (cmd) and run:
        cd "C:\Program Files\PostgreSQL\16\bin"

  Restore the Database using pg_restore
     - Run the following command:
        pg_restore -c -U postgres -W -F t -d <empty database> <Downloaded-Database-Path>
        Example: 
        pg_restore -c -U postgres -W -F t -d trashtrack C:\Users\bacal\Downloads\trashtrack.tar

  Explanation of Flags:
    -c → Drops existing objects before restoring (cleans the database).
    -U postgres → Uses the postgres user.
    -W → Prompts for the password.
    -F t → Specifies that the backup is in tar format.
    -d trashtrack → Restores the backup into the trashtrack database.

-----------------------------------------------
SetUp Backend 
    Node.js
        - Download and Install Node.js
        - Go to Node.js official website (https://nodejs.org/en)
        - Download the LTS (Long-Term Support) version
        - Run the installer 
        - Verify Installation, Open Command Prompt (cmd) or PowerShell, then run:
            node -v   # Check Node.js version

    Open CMD, cd the path of the folder named "backend" from flashdrive project files.
    then type: npm install

    Postgre Connection
        - open the "backend" folder in VS Code, open the file name "server.js"
        - inside the server.js, find the pool connection:
            user: 'postgres',
            host: 'localhost',
            database: 'trashtrack', //database name
            password: '123456', //your DB password
            port: 5432,
        - modify this connection according to your Postgre Database Credentials

    Lastly, run the server in VS Code terminal (cd backend) type:
        node server.js

-----------------------------------------------
SetUp Frontend
    Install the trashtrack.apk directly to your physical device.
        - open the trashtrack app, then type the IP address that your mobile phone and PC/Laptop(backend server was running), (You can find the IP address in CMD then type: ipconfig).




    if you don't want to use the APK file, then you can manually install the app by the following:    
        Flutter (Download and install)
            - Go to the Flutter official website (https://flutter.dev)
            - Download the latest Flutter SDK (flutter_Windows.zip).
            - Extract the zip file, then create folder name "src", then copy the extracted folder "flutter" to C:\src.
            - Set Up Environment Variables
            - Search "Environment Variables" in Windows and open it.
            - Under User Variables, find "Path" and click Edit.
            - Click New and add:
                C:\src\flutter\bin
            - Click OK,OK. (restart your PC if needed).
        
        Android Studio & SDK (Download and install)
            - Download and install Android Studio (https://developer.android.com/studio)

        Visual Studio Code (Download and install)
            - go to download and install VS Code (https://code.visualstudio.com/download)
            - Open VS Code → Install Flutter & Dart Extensions from the Extensions
        
        To Verify overall Installation, Open the folder named "frontend" in VS Code then Open terminal, then run:
            flutter doctor
        This checks if everything is installed correctly.

        Now open the VS Code, and open folder named "frontend" from the flashdrive, add and go to terminal (if not on the path then type: cd frontend), 
        then type: flutter pub get
        then to run the app type: flutter run

        if running through physical phone:
            - allow Debugging mode(make sure it was on: USB Debugging, Install via USB, USB Debuggin(Security Settings)) on phone's settings before running
            - once installed, open the trashtrack app
            - type the IP address from the server
        if running through android emulator
            - open trashtrack app
            - type IP address: 10.0.2.2
            
-----------------------------------------------
Setup Payment
    for security purposes, you can create your own account in PAYMONGO
        - open the official website of PAYMONGO (https://www.paymongo.com/) and create your account
        - once logged In, click Developers (left side), copy the secret key
        - go back to folder named "backend" from flashdrive, open .env file then change PAYMONGO_SECRE: "YourSecretKey", then save and rerun the server again in terminal: node server.js

    Ngrok (Download and install)
        - Go to the official website: https://ngrok.com/download
        - Click "Download for Windows" (big button).
        - Extract the downloaded ZIP file to a folder ("backend" from the flashdrive).
        - Open "Environment Variables" in Windows.
        - find Path and click Edit, Click New, then add: C:\"path of the backend folder", click OK, OK
        - open new CMD, type: ngrok config add-authtoken 2oZ1DnI1PvQKQGZVKnVk58ylXSh_2YXcqE6E16WfUJsVgt9DG
        - then type: ngrok http 3000
        - find the Forwarding, copy the http (example: https://4aa8-216-247-22-136.ngrok-free.app) (this will be needed for paymongo later)


        - open the website (https://developers.paymongo.com/) login your PAYMONGO Account
        - on the top, click API Reference, then on the left side bar, scroll down and find WEBHOOKS and click create a webhook.
        - on the right side paste your SECRETKEY to the credentials basic (just empty the password).
        - in the BODY PARAMS, click data object, click attributes object, under it:
            - in url, type: "paste the ngrok link here"/webhooks/paymongo 
                example: https://d8b7-216-247-20-240.ngrok-free.app/webhooks/paymongo
            - in events, click add string , type: checkout_session.payment.paid
        - and lastly click "Try it!"


        All the steps and requirements may vary depending on the device, operating system and environment.
