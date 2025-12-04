{ den, ... }:
{
  den.aspects."email-personal" = {
    homeManager =
      { config, ... }:
      {
        accounts.email.accounts.personal = {
          primary = true;
          address = "wesley.thorsen@gmail.com";
          realName = "Wesley Thorsen";
          userName = "wesley.thorsen@gmail.com";
          flavor = "gmail.com";
          passwordCommand = "pass show mail/gmail";
          maildir.path = "personal";
        };
      };
  };
}
