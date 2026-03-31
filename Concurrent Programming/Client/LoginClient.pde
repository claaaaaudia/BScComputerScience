import java.io.*;
import java.net.Socket;
import java.io.IOException;

public class LoginClient {
    ClientConnection client;
  
    public LoginClient(ClientConnection client){
        this.client = client;
    }
    
    public ClientConnection getClient() {
      return client;
    }

    String createAccount(String username, String password) throws IOException {
        if (client == null || client.out == null) {
          throw new IOException("Not connected to server");
        }
        
        if (username.length() == 0 || password.length() == 0){
          throw new IOException("Usarname/Password cannot be null.");
        }
        
        if (username.contains(",") || password.contains(",")) {
          return "Username and password cannot contain commas.";
        }

        else {
          String command = String.format("create_account:%s#%s", username, password);
          client.sendCommand(command);
          return "Account creation command sent.";  
        }
    }

    String login(String username, String password) throws IOException {
        if (client == null || client.out == null) {
          throw new IOException("Not connected to server");
        }
        
        if (username.length() == 0 || password.length() == 0){
          throw new IOException("Usarname/Password cannot be null.");
        }
        else {
          String command = String.format("login:%s#%s", username, password);
          client.sendCommand(command);
          return "Login command sent.";  
        }
    }

    String logout(String username) throws IOException {
        if (client == null || client.out == null) {
          throw new IOException("Not connected to server");
        }
        
        String command = String.format("logout:%s", username);
        client.sendCommand(command);
        return "Logout command sent.";  
    }

    String deleteAccount(String username, String password) throws IOException {
        if (client == null || client.out == null) {
          throw new IOException("Not connected to server");
        }
        
        String command = String.format("remove_account:%s#%s", username, password);
        client.sendCommand(command);
        return "Account deletion command sent.";  
    }

    String[] getTopTen() throws IOException {
        if (client == null || client.out == null) {
            throw new IOException("Not connected to server");
        }
        
        client.sendCommand("top_ten");
        return new String[0];
    }
    
    String joinLobby(String username) {
        if (client == null || client.out == null) {
          return "Not connected to server";
        }
        
        String command = String.format("join:%s", username.trim());
        client.sendCommand(command);
        return "Lobby join request sent.";  
    }
    
    String leaveLobby(String username) {
        if (client == null || client.out == null) {
          return "Not connected to server";
        }
        
        String command = "leave:" + username;
        client.sendCommand(command);
        
        return "Lobby leave request sent.";
    }
    
}
