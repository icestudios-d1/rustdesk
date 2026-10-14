use hbb_common::{
    config::Config,
    password_security::{decrypt_str_or_original, encrypt_str_or_original},
    ResultType,
};
use serde_derive::{Deserialize, Serialize};
use std::path::PathBuf;

const ENC_VERSION: &str = "00";
const MAX_PASSWORD_LEN: usize = 128;

#[derive(Debug, Default, Clone, Serialize, Deserialize)]
pub struct Entry {
    pub id: String,
    #[serde(default)]
    pub alias: String,
    #[serde(default)]
    pub group: String,
    #[serde(default)]
    pub note: String,
    #[serde(default)]
    pub password: String,
}

#[derive(Debug, Default, Serialize, Deserialize)]
struct Book {
    #[serde(default)]
    entries: Vec<Entry>,
}

fn path() -> PathBuf {
    Config::path("phonebook.json")
}

fn load() -> Book {
    let Ok(data) = std::fs::read_to_string(path()) else {
        return Book::default();
    };
    serde_json::from_str(&data).unwrap_or_default()
}

fn store(book: &Book) -> ResultType<()> {
    let data = serde_json::to_string_pretty(book)?;
    let path = path();
    std::fs::write(&path, data)?;
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        std::fs::set_permissions(&path, std::fs::Permissions::from_mode(0o600))?;
    }
    Ok(())
}

/// Entries with the password decrypted, as a JSON array.
pub fn list_json() -> String {
    let mut entries = load().entries;
    for e in entries.iter_mut() {
        e.password = decrypt_str_or_original(&e.password, ENC_VERSION).0;
    }
    entries.sort_by_key(|e| (e.group.to_lowercase(), e.alias.to_lowercase(), e.id.clone()));
    serde_json::to_string(&entries).unwrap_or_else(|_| "[]".to_owned())
}

/// Inserts or replaces the entry with the same id. Takes a JSON `Entry` whose
/// password is plaintext.
pub fn save_json(entry: &str) -> ResultType<()> {
    let mut entry: Entry = serde_json::from_str(entry)?;
    entry.id = entry.id.replace(' ', "");
    if entry.id.is_empty() {
        hbb_common::bail!("empty id");
    }
    entry.password = encrypt_str_or_original(&entry.password, ENC_VERSION, MAX_PASSWORD_LEN);
    let mut book = load();
    match book.entries.iter_mut().find(|e| e.id == entry.id) {
        Some(e) => *e = entry,
        None => book.entries.push(entry),
    }
    store(&book)
}

pub fn remove(id: &str) -> ResultType<()> {
    let mut book = load();
    book.entries.retain(|e| e.id != id);
    store(&book)
}

/// Replaces the whole book from a JSON array of plaintext entries.
pub fn import_json(data: &str) -> ResultType<usize> {
    let entries: Vec<Entry> = serde_json::from_str(data)?;
    let mut book = load();
    let mut n = 0;
    for mut entry in entries {
        entry.id = entry.id.replace(' ', "");
        if entry.id.is_empty() {
            continue;
        }
        entry.password = encrypt_str_or_original(&entry.password, ENC_VERSION, MAX_PASSWORD_LEN);
        match book.entries.iter_mut().find(|e| e.id == entry.id) {
            Some(e) => *e = entry,
            None => book.entries.push(entry),
        }
        n += 1;
    }
    store(&book)?;
    Ok(n)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn entry_json_roundtrip_defaults() {
        let e: Entry = serde_json::from_str(r#"{"id":"123"}"#).unwrap();
        assert_eq!(e.id, "123");
        assert!(e.password.is_empty());
    }
}
