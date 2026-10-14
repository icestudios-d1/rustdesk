use base::config::keys;
use hbb_common::config;

/// Defaults and locked options for this stripped-down build. Applied before the
/// optional custom client config, so a signed `custom.txt` can still change them.
pub fn apply() {
    let mut default_settings = config::DEFAULT_SETTINGS.write().unwrap();
    default_settings.insert(keys::OPTION_APPROVE_MODE.to_owned(), "password".to_owned());
    default_settings.insert(
        keys::OPTION_VERIFICATION_METHOD.to_owned(),
        "use-permanent-password".to_owned(),
    );
    drop(default_settings);

    let mut overwrite_settings = config::OVERWRITE_SETTINGS.write().unwrap();
    for k in [
        keys::OPTION_ENABLE_TERMINAL,
        keys::OPTION_ENABLE_CAMERA,
        keys::OPTION_ENABLE_TUNNEL,
        keys::OPTION_ENABLE_REMOTE_PRINTER,
        keys::OPTION_ENABLE_LAN_DISCOVERY,
        keys::OPTION_ALLOW_AUTO_UPDATE,
    ] {
        overwrite_settings.insert(k.to_owned(), "N".to_owned());
    }
    drop(overwrite_settings);

    // Upstream's updater would replace this build with stock RustDesk.
    config::OVERWRITE_LOCAL_SETTINGS
        .write()
        .unwrap()
        .insert(keys::OPTION_ENABLE_CHECK_UPDATE.to_owned(), "N".to_owned());

    config::BUILTIN_SETTINGS
        .write()
        .unwrap()
        .insert(keys::OPTION_HIDE_HELP_CARDS.to_owned(), "Y".to_owned());
}
