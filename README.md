#VHX Ruby Gem
The following are instructions for using the VHX Ruby Gem.

##References
* [VHX Api Documentation](http://dev.vhx.tv/docs/api/)
* [Oauth2 Ruby Gem](https://github.com/intridea/oauth2)

##Authentication

For application-only authentication, you will need an api key. Borrowing heavily from [Twitter's api](https://dev.twitter.com/oauth), "application-only authentication is a form of authentication where your application makes API requests on its own behalf, without a user context."

For application-user authentication, you will need an access token. Borrowing heavily from [Twitter's api](https://dev.twitter.com/oauth), "Your signed request both identifies your application’s identity in addition to the identity accompanying granted permissions of the end-user you’re making API calls on behalf of, represented by the user’s access token."

If you are looking to access your own data, then the application-only authentication is the way to go. If you are looking to access data on behalf of an end user of your app, then application-user authentication is for you.

###API Key (Application-only authentication)

To obtain an api key, please visit [TBD, but Kevin's PR](https://github.com/vhx/crystal/pull/1073)

###Access Token (Application-User Authentication)

To obtain an access token, you will need the [Oauth2 Gem](https://github.com/intridea/oauth2), a VHX client id, and VHX client secret. Once you have these credentials, instantiate a OAuth client:

```ruby
client_id     = '9ac56e0574439fd569fbb5a47986d6dffff01a790429cc2b46cbfdd5e47f59ee'
client_secret = '5fcddd236f9b9fce172a34af47805e426c3a66ecf36e4c558807edcc2d52a389'

client        = OAuth2::Client.new(client_id, client_secret, site: 'https://api.vhx.tv')
```

Then, you will need to generate an authorization url to redirect to. This authorization url will walk your end user through the authorization process with VHX:

```ruby
client.auth_code.authorize_url(redirect_uri: 'https://youapp.com/oauth2/callback')
```

Once your user has authenticatecd with VHX, they will be redirected to the uri that you provide, in this example (https://youapp.com/oauth2/callback). You will receive this incoming request, which will come with a code, in your app. From this point, you can use the Oauth Client to retreive a token to use with the VHX Gem.

```ruby
code  = params[:code]
token = client.auth_code.get_token(code, redirect_uri: 'https://youapp.com/oauth2/callback', grant_type: 'client_credentials')

token         = token.token
refresh       = token.refresh_token
expires_at    = token.expires_at
```

###Make your first request

Now that you have either an api key or access_token you are ready to make your first request!

```ruby
credentials = {
  oauth_token: {
    access_token:  token,
    refresh_token: refresh,
    expires_at:    expires_at
  }
}
```

OR

```ruby
credentials = {
  api_key: api_key
}
```

Instantiate the VHX Client:

```ruby
vhx = Vhx::Client.new(client_id, client_secret, credentials)
```



