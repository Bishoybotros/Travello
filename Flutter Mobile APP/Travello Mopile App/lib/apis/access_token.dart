// ignore: deprecated_member_use
import 'package:googleapis_auth/auth_io.dart';

class AccessToken {
  static String firebaseMessaginScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  Future<String> getaccesstoken() async {
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(
          {
            "type": "service_account",
            "project_id": "travello-2ed88",
            "private_key_id": "a053a91b30e48c139e972368d51f26b7893b4847",
            "private_key":
                "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC1wcFh1vf0Dozg\nRJQ17x6trGNqMgQ+SeE+EKowGkX2rcos0hoUBRKRQYGRUwL9HMX5KjOExJtL735H\nbkfwLm+cjS4JFHZr30ZUSVRxQJhs9E2aroqgcqw88rDo07x2blGp1J+2/pqWSgv7\nZzO06zSwz7PbJCVa5JV34wZCXcJoY1gF4XeIscr8E7ws/CZpCWNC9XK5JQIYo/DS\nKrZ+91TAC6dqNUQSheSbUW9J7m/48FSvCh80JsKk1JFgB372Ei4A5KfAdIaKRCLV\nx+MnKP0xfH+SPzPYqV2pIQjtYDxxqW6FiKdEl+MxcOBJWKDOwQPnoUfOai77Ap4a\nfBatgYezAgMBAAECggEAAKfo1z4L2gUdbAfDUyiAP1cyaqUwj7r7hZpQyuilXP0G\nkD/X2T+lcAHBAnG+voQWkM4ernl5J/5+wao7tzmrrHBz/JNm0//TxKUZGWmGw0nk\nZ8z+chLH3VZw3f45nWHLiKXcR7BGhYlR3r/iF2KL56FwQDeyrM/LXEnk8WNeOrsz\necfnZQWEl2WS95fsnCV98KUk790C97IIlyFLT/bj/yNg0cvwF5JW0TKJqazvHp9K\nM7NtY0tqfLJ2XUPl5qchk0HGhbUo0v1tAyW4jzu5M4nJjWW4dABmb9VuB0Ofgpzz\nqLI6bVQm24pSeAOf6BRkgNiRovNleukMq7saMuREXQKBgQD1OgyxkGiXeQAjqCQM\nTP63qtOwEuWsEDACWK749WtCeiGB7rqv5jNom/iKXxIfOYyzKSD+GNucNCdCU15X\n5tsjToUgWpEnEEJuwu7+5T9CAPpD+tvKSUOvXBjVzcNZytZv0QJjsfELSiFUEZKC\nfPqFX9Tp6nkw0fDteGd09cu+VQKBgQC9veO82Yfcd4gbUHZ2Cpy1MCAMP3hZDme3\nF6V6JTNaOZoXOKEgVydOfrFD8UAfb2K9IrnyUit0QRqR6keNS8wsX7onE/ddJmMf\nKD5rEoUiR8szRei3QZ6ThxZrvgc1vq3lpgiQ6BSCuRypnwwFvjzu2Odyb4rGn5DK\nTvowEQyl5wKBgQDIfGkcUn/wNtDSVgkCtYAaEON4tDppbeKSSIbkq2DBvK/gVpjy\nbjXhdILCPe/G73oEj7+VfiUtk8X1B8u9+dN3Dh7w0JqTYUuu2lgitLH++GWjZliD\nDVr050q2ob7wjlC6ohpd/4CeRkDxRlyNqjf3Ct47T6M9MqbSvvl2Oe4U8QKBgQC4\n8Qi0v3ccnmnM7d25atiaBsGGDqt4aoEPRn4lk3L9Y53dOnZa9ng6m2SfK9xrh38/\niUSjfBIc64RBa5C4mYP2UIw6oMyAP/VnnitQ5CleY4odfOu7C7vMYmSpOfz/Fs+b\nQv2geIXdcR8N+heW1XnA+SyHL0+eEFPpzZcxGL0ySwKBgHFAlOkMNZJT19JSCOoc\ntZVZwsVGDfu8GQvOMP4Y4kB5mrJrNT5RXTjRIxWR/vq5k/fJ/O+NwITjPGPmdvp5\nVskeoSeaidkEcGjk6yy5SCbxDadbt4TwmFD+FcgIfzs3cHdwfyH9zRUuDpnfsGFi\nTHo3GaBqFfhPONJWLKXKonl6\n-----END PRIVATE KEY-----\n",
            "client_email":
                "firebase-adminsdk-r1f1n@travello-2ed88.iam.gserviceaccount.com",
            "client_id": "103860786971633423184",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url":
                "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url":
                "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-r1f1n%40travello-2ed88.iam.gserviceaccount.com",
            "universe_domain": "googleapis.com"
          },
        ),
        [firebaseMessaginScope]);
        final accesstoken = client.credentials.accessToken.data;
        return accesstoken;
  }
}
