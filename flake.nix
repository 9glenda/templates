{
  description = "A collection of flake templates";

  outputs = { self }: {

    templates = {

      golang = {
        path = ./golang;
        description = "A basic golang flake";
      };

    };

    defaultTemplate = self.templates.golang;

  };
}

