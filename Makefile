SHELL:=/bin/zsh

# Log helpers: a blank line and a bold "==>" header so each step stands out
# in the install log (same style Homebrew uses). Colours render in GitHub Actions too.
define log
@printf "\n\033[1;34m==> \033[1;37m%s\033[0m\n" "$(1)"
endef

define done
@printf "\033[1;32m==> Done\033[0m\n"
endef

all: sudo xdg_specs brew stow ohmyzsh stow-ohmyzsh-custom ohmyzsh-plugins duti rust asdf aws-credentials gpg-keys

sudo:
ifndef CI
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
endif

xdg_specs:
	$(call log,Creating XDG Base Directory Specification)
	@mkdir -p "$(HOME)/.cache"
	@mkdir -p "$(HOME)/.config"
	@mkdir -p "$(HOME)/.local/share"
	@mkdir -p "$(HOME)/.local/state"
	@mkdir -p "$(HOME)/.local/runtime"
	@chmod 0700 "$(HOME)/.local/runtime"
	@mkdir -p "$(XDG_CACHE_HOME)/zsh"
	@mkdir -p "$(XDG_CONFIG_HOME)/zsh"
	@mkdir -p "$(XDG_STATE_HOME)/zsh"
	@cp -f dot-files/dot-zshenv "$(HOME)/.zshenv"
	$(call done)

brew: brew-install brew-formulae brew-casks

brew-install:
# Skip if running in CI because Homebrew is already installed in macos-latest image
ifndef CI
	$(call log,Installing Homebrew)
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	$(call done)
endif
ifdef CI
	$(call log,Updating Brew formulae)
	@/opt/homebrew/bin/brew update
	@/opt/homebrew/bin/brew upgrade
	$(call done)
endif

brew-formulae:
	$(call log,Installing Brew formulae)
	@/opt/homebrew/bin/brew bundle --file=homebrew/Brewfile
	$(call done)

brew-casks:
ifndef CI
	$(call log,Installing Brew casks)
	@/opt/homebrew/bin/brew bundle --file=homebrew/Caskfile
	$(call done)
endif

ohmyzsh:
	$(call log,Installing Oh My Zsh)
	@sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
	$(call done)

stow:
	$(call log,Installing dotfiles)
	@/opt/homebrew/bin/stow --target=$(HOME) --dotfiles --verbose=1 --no-folding --adopt --restow dot-files
	$(call done)

stow-ohmyzsh-custom:
	$(call log,Installing Oh My Zsh custom theme)
	@/opt/homebrew/bin/stow --target=$(XDG_CONFIG_HOME)/zsh/ohmyzsh/custom --verbose=1 --no-folding --adopt --restow ohmyzsh-custom
	$(call done)

ohmyzsh-plugins:
	$(call log,Installing zsh-autosuggestions and zsh-syntax-highlighting plugins)
	@git clone https://github.com/zsh-users/zsh-autosuggestions $(ZDOTDIR)/ohmyzsh/custom/plugins/zsh-autosuggestions
	@git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $(ZDOTDIR)/ohmyzsh/custom/plugins/zsh-syntax-highlighting
	$(call done)

duti:
	ls -al $(HOME)
	ls -al $(XDG_CONFIG_HOME)
	ls -al $(XDG_CONFIG_HOME)/zsh
	$(call log,Setting default applications)
	@/opt/homebrew/bin/duti -v .duti
	$(call done)

rust:
	$(call log,Installing Rust)
	@/opt/homebrew/bin/brew link --force rustup
	@/opt/homebrew/bin/rustup default stable
	$(call done)

asdf: asdf-plugins asdf-nodejs asdf-python asdf-ruby

asdf-plugins:
	$(call log,Adding asdf-alias plugin)
	@asdf plugin add alias
	@asdf plugin add nodejs
	@asdf plugin add python
	@asdf plugin add ruby
	$(call done)

asdf-nodejs:
	$(call log,Installing nodejs $$(asdf cmd nodejs resolve lts))
	@asdf set --home nodejs $$(asdf cmd nodejs resolve lts)
	@asdf install nodejs
	$(call done)

asdf-python:
	$(call log,Installing python $$(asdf latest python 3))
	@asdf set --home python $$(asdf latest python 3)
	@asdf install python
	$(call done)

asdf-ruby:
	$(call log,Installing ruby $$(asdf latest ruby 3))
	@asdf set --home ruby $$(asdf latest ruby 3)
	@asdf install ruby
	$(call done)

aws-credentials: aws-credentials-arqshoah aws-credentials-legado

aws-credentials-arqshoah:
	$(call log,Configuring AWS credentials for Arqshoah)
	@[[ -n $$aws_access_key_id ]] || read -rp "Enter AWS Access Key ID for Arqshoah: " aws_access_key_id; \
	/opt/homebrew/bin/aws configure set aws_access_key_id $$aws_access_key_id --profile arqshoah;

	@[[ -n $$aws_secret_access_key ]] || read -rp "Enter AWS Secret Access Key for Arqshoah: " aws_secret_access_key; \
	/opt/homebrew/bin/aws configure set aws_secret_access_key $$aws_secret_access_key --profile arqshoah
	$(call done)

aws-credentials-legado:
	$(call log,Configuring AWS credentials for Legado)
	@[[ -n $$aws_access_key_id ]] || read -rp "Enter AWS Access Key ID for Legado: " aws_access_key_id; \
	/opt/homebrew/bin/aws configure set aws_access_key_id $$aws_access_key_id --profile legado;

	@[[ -n $$aws_secret_access_key ]] || read -rp "Enter AWS Secret Access Key for Legado: " aws_secret_access_key; \
	/opt/homebrew/bin/aws configure set aws_secret_access_key $$aws_secret_access_key --profile legado;
	$(call done)

gpg-keys:
	$(call log,Setup GPG keys)
	@mkdir -p $(GNUPGHOME)
	@chown -R $$(whoami) $(GNUPGHOME)
	@find $(GNUPGHOME) -type f -exec chmod 600 {} \;
	@find $(GNUPGHOME) -type d -exec chmod 700 {} \;
ifndef CI
	@read -rp "Enter path to GPG key backup: " path_to_gpg_key; \
	/opt/homebrew/bin/gpg --import-options restore --import $$path_to_gpg_key
endif
	$(call done)

.PHONY: macos
macos:
	$(call log,Configuring macOS)
	@./macos.sh
	$(call done)

# Tests

test-all: test-stow test-asdf-tools test-aws-credentials test-gpg

test-stow:
	$(call log,Testing dotfiles)
	test -L "$(XDG_CONFIG_HOME)/asdf/asdfrc"
	test -L "$(XDG_CONFIG_HOME)/asdf/default-gems"
	test -L "$(XDG_CONFIG_HOME)/aws/config"
	test -L "$(XDG_CONFIG_HOME)/git/config"
	test -L "$(XDG_CONFIG_HOME)/git/ignore"
	test -L "$(XDG_CONFIG_HOME)/ngrok/ngrok.yml"
	test -L "$(XDG_CONFIG_HOME)/zsh/.zshrc"
	test -L "$(XDG_CONFIG_HOME)/zsh/.zlogin"
	test -L "$(HOME)/.zshenv"
	test -L "$(XDG_CONFIG_HOME)/zsh/ohmyzsh/custom/themes/robbyrussell-custom.zsh-theme"
	$(call done)

test-asdf-tools:
	$(call log,Testing asdf tool versions)
	@[[ -f "$(HOME)/.tool-versions" && -n "$(HOME)/.tool-versions" ]]
	$(call done)

test-aws-credentials:
	$(call log,Testing AWS credentials)
	@echo $(XDG_DATA_HOME)
	@cat "$(XDG_DATA_HOME)/aws/credentials"
	@[[ -f "$(XDG_DATA_HOME)/aws/credentials" && -n "$(XDG_DATA_HOME)/aws/credentials" ]]
	$(call done)

test-gpg:
	$(call log,Testing GPG keys)
	@[[ -d "$(XDG_DATA_HOME)/gnupg" && -O "$(XDG_DATA_HOME)/gnupg" && -r "$(XDG_DATA_HOME)/gnupg" && -w "$(XDG_DATA_HOME)/gnupg" && -x "$(XDG_DATA_HOME)/gnupg" ]]
	$(call done)
