# dotfiles

My dotfiles

## Get started

### Git global config

以下の Git global config は事前に設定してください。

```shell
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git config --global user.signingkey "YOUR_GPG_KEY_ID"
```

GPG Key についてはこちらを参照してください。

https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account

### dotfiles

dotfiles は `dotfiles/` 配下で通常のファイル名として管理します。

```text
dotfiles/.bash_profile
dotfiles/.vimrc
dotfiles/.config/git/ignore
```

`install.sh` 実行時に Ansible が一時的な chezmoi source directory を作成し、chezmoi 形式の `dot_*` ファイル名へ変換してから適用します。

### インストール

インストールは以下のコマンドで完了します。

```shell
./install.sh
```

Ansible の `become` を使うため、実行中に sudo パスワードを求められます。
