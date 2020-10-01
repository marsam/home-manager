{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.ledger;

  arguments = optionals cfg.strict [ "--strict" ]
    ++ optionals cfg.download [ "--download" ]
    ++ optionals cfg.explicit [ "--explicit" ]
    ++ optionals cfg.pedantic [ "--pedantic" ]
    ++ optionals cfg.dayBreak [ "--day-break" ]
    ++ optionals cfg.noAliases [ "--no-aliases" ]
    ++ optionals cfg.timeColon [ "--time-colon" ]
    ++ optionals cfg.permissive [ "--permissive" ]
    ++ optionals cfg.checkPayees [ "--check-payees" ]
    ++ optionals cfg.decimalComma [ "--decimal-comma" ]
    ++ optionals cfg.recursiveAliases [ "--recursive-aliases" ]
    ++ optionals (cfg.file != null) [ "--file ${cfg.file}" ]
    ++ optionals (cfg.priceDB != null) [ "--price-db ${cfg.priceDB}" ]
    ++ optionals (cfg.valueExpr != null) [ "--value-expr ${cfg.valueExpr}" ]
    ++ optionals (cfg.masterAccount != null)
    [ "--master-account ${cfg.masterAccount}" ]
    ++ optionals (cfg.inputDateFormat != null)
    [ "--input-date-format ${cfg.inputDateFormat}" ]
    ++ optionals (cfg.priceExpectedFreshness != null)
    [ "--price-exp ${cfg.priceExpectedFreshness}" ] ++ cfg.extraArguments;
in {
  meta.maintainers = [ maintainers.marsam ];

  options.programs.ledger = {
    enable = mkEnableOption "ledger";

    package = mkOption {
      type = types.package;
      default = pkgs.ledger;
      defaultText = literalExample "pkgs.ledger";
      description = ''
        The ledger package to install.
      '';
    };

    checkPayees = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable strict and pedantic checking for payees as well as accounts,
        commodities and tags. This only works in conjunction with strict or
        pedantic.
      '';
    };

    dayBreak = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Break up register report of timelog entries that span multiple days by
        day.
      '';
    };

    decimalComma = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Direct Ledger to parse journals using the European standard comma as a
        decimal separator, not the usual period.
      '';
    };

    download = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Direct Ledger to download prices.
      '';
    };

    explicit = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Direct Ledger to require pre-declarations for entities (such as
        accounts, commodities and tags) rather than taking entities from cleared
        transactions as defined. This option is useful in combination with
        <option>--strict</option> or <option>--pedantic</option>.
      '';
    };

    inputDateFormat = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Specify the input date format for journal entries.
      '';
    };

    masterAccount = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Prepend all account names with the argument.
      '';
    };

    noAliases = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Ledger does not expand any aliases if this option is specified.
      '';
    };

    pedantic = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Accounts, tags or commodities not previously declared will cause errors.
      '';
    };

    file = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Read journal data from file.
      '';
    };

    permissive = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Quiet balance assertions.
      '';
    };

    priceDB = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Specify the location of the price entry data file.
      '';
    };

    priceExpectedFreshness = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = ''
        Set the expected freshness of price quotes, in minutes. That is, if the
        last known quote for any commodity is older than this value, and if
        <option>--download</option> is being used, then the Internet will be
        consulted again for a newer price. Otherwise, the old price is still
        considered to be fresh enough.
      '';
    };

    strict = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Ledger normally silently accepts any account or commodity in a posting,
        even if you have misspelled a commonly used one. The option
        <option>--strict</option> changes that behavior. While running with
        <option>--strict</option>, Ledger interprets all cleared transactions as
        correct, and if it encounters a new account or commodity (same as a
        misspelled commodity or account) it will issue a warning giving you the
        file and line number of the problem.
      '';
    };

    recursiveAliases = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Normally, ledger only expands aliases once. With this option, ledger
        tries to expand the result of alias expansion recursively, until no more
        expansions apply.
      '';
    };

    timeColon = mkOption {
      type = types.bool;
      default = false;
      description = ''
        The <option>--time-colon</option> option will display the value for a
        seconds based commodity as real hours and minutes.
      '';
    };

    valueExpr = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Set a global value expression annotation.
      '';
    };

    extraArguments = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Extra arguments to pass to ledger.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    # XDG support will be available in the next release. https://github.com/ledger/ledger/pull/1960
    xdg.configFile."ledger/ledgerrc" =
      mkIf (arguments != [ ]) { text = concatStringsSep "\n" arguments; };
  };
}
