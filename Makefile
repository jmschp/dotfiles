SHELL:=/bin/zsh

all: sudo xdg_specs brew stow ohmyzsh stow-ohmyzsh-custom ohmyzsh-plugins duti asdf aws-credentials gpg-keys

sudo:
ifndef CI
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
endif

xdg_specs:
	@echo "Creating XDG Base Directory Specification"
	@mkdir -p "$(HOME)/.cache"
	@mkdir -p "$(HOME)/.config"
	@mkdir -p "$(HOME)/.local/share"
	@mkdir -p "$(HOME)/.local/state"
	@mkdir -p "$(HOME)/.local/runtime"
	@chmod 0700 "$(HOME)/.local/runtime"
	@mkdir -p "$(XDG_STATE_HOME)/zsh"
	@mkdir -p "$(XDG_CACHE_HOME)/zsh"
	@echo "Done"

brew: brew-install brew-formulae brew-casks

brew-install:
# Skip if running in CI because Homebrew is already installed in macos-latest image
ifndef CI
	@echo "Installing Homebrew"
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@echo "Done"
endif
ifdef CI
	@echo "Updating Brew formulae"
	@/opt/homebrew/bin/brew update
	@/opt/homebrew/bin/brew upgrade
	@echo "Done"
endif

brew-formulae:
	@echo "Installing Brew formulae"
	@/opt/homebrew/bin/brew bundle --file=homebrew/Brewfile
	@echo "Done"

brew-casks:
ifndef CI
	@echo "Installing Brew casks"
	@/opt/homebrew/bin/brew bundle --file=homebrew/Caskfile
	@echo "Done"
endif

stow:
	@echo "Installing dotfiles"
	@/opt/homebrew/bin/stow --target=$(HOME) --dotfiles --verbose=1 --no-folding --adopt --restow dot-files
	@echo "Done"

ohmyzsh:
	@echo "Installing Oh My Zsh"
	@sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	@echo "Done"

stow-ohmyzsh-custom:
	@echo "Installing Oh My Zsh custom theme"
	echo $(ZSH)
	echo "$(ZDOTDIR)/ohmyzsh"
	ls -al $(HOME)
	ls -al $(XDG_CONFIG_HOME)
	ls -al $(XDG_CONFIG_HOME)/zsh
	@/opt/homebrew/bin/stow --target=$(XDG_CONFIG_HOME)/zsh/ohmyzsh/custom --verbose=1 --no-folding --adopt --restow ohmyzsh-custom
	@echo "Done"

ohmyzsh-plugins:
	@echo "Installing zsh-autosuggestions and zsh-syntax-highlighting plugins"
	@git clone https://github.com/zsh-users/zsh-autosuggestions $(ZDOTDIR)/ohmyzsh/custom/plugins/zsh-autosuggestions
	@git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $(ZDOTDIR)/ohmyzsh/custom/plugins/zsh-syntax-highlighting
	@echo "Done"

duti:
	@echo "Setting default applications"
	@/opt/homebrew/bin/duti -v .duti
	@echo "Done"

rust:
ifndef CI
	@echo "Installing Rust"
	@/opt/homebrew/bin/brew link --force rustup
	@/opt/homebrew/bin/rustup default stable
	@echo "Done"
endif

asdf: asdf-plugins asdf-nodejs asdf-python asdf-ruby

asdf-plugins:
	@echo "Adding asdf-alias plugin"
	@asdf plugin add alias
	@asdf plugin add nodejs
	@asdf plugin add python
	@asdf plugin add ruby
	@echo "Done"

asdf-nodejs:
	@echo "Installing nodejs $$(asdf cmd nodejs resolve lts --latest-available)"
	@asdf set --home nodejs $$(asdf cmd nodejs resolve lts --latest-available)
	@asdf install nodejs
	@echo "Done"

asdf-python:
	@echo "Installing python $$(asdf latest python 2) and $$(asdf latest python 3)"
	@asdf set --home python $$(asdf latest python 2) $$(asdf latest python 3)
	@asdf install python
	@echo "Done"

asdf-ruby:
	@echo "Installing ruby $$(asdf latest ruby 3)"
	@asdf set --home ruby $$(asdf latest ruby 3)
	@asdf install ruby
	@echo "Done"

aws-credentials: aws-credentials-arqshoah aws-credentials-legado

aws-credentials-arqshoah:
	@echo "Configuring AWS credentials for Arqshoah"
	@[[ -n $$aws_access_key_id ]] || read -rp "Enter AWS Access Key ID for Arqshoah: " aws_access_key_id; \
	/opt/homebrew/bin/aws configure set aws_access_key_id $$aws_access_key_id --profile arqshoah;

	@[[ -n $$aws_secret_access_key ]] || read -rp "Enter AWS Secret Access Key for Arqshoah: " aws_secret_access_key; \
	/opt/homebrew/bin/aws configure set aws_secret_access_key $$aws_secret_access_key --profile arqshoah
	@echo "Done"

aws-credentials-legado:
	@echo "Configuring AWS credentials for Legado"
	@[[ -n $$aws_access_key_id ]] || read -rp "Enter AWS Access Key ID for Legado: " aws_access_key_id; \
	/opt/homebrew/bin/aws configure set aws_access_key_id $$aws_access_key_id --profile legado;

	@[[ -n $$aws_secret_access_key ]] || read -rp "Enter AWS Secret Access Key for Legado: " aws_secret_access_key; \
	/opt/homebrew/bin/aws configure set aws_secret_access_key $$aws_secret_access_key --profile legado;
	@echo "Done"

gpg-keys:
	@echo "Setup GPG keys"
	@mkdir -p $(GNUPGHOME)
	@chown -R $$(whoami) $(GNUPGHOME)
	@find $(GNUPGHOME) -type f -exec chmod 600 {} \;
	@find $(GNUPGHOME) -type d -exec chmod 700 {} \;
ifndef CI
	@read -rp "Enter path to GPG key backup: " path_to_gpg_key; \
	/opt/homebrew/bin/gpg --import-options restore --import $$path_to_gpg_key
endif
	@echo "Done"

.PHONY: macos
macos:
	@echo "Configuring macOS"
	@./macos.sh
	@echo "Done"

# Tests

test-all: test-stow test-asdf-tools test-aws-credentials test-gpg

test-stow:
	@echo "Testing dotfiles"
	@test -L "$(XDG_CONFIG_HOME)/asdf/asdfrc"
	@test -L "$(XDG_CONFIG_HOME)/asdf/default-gems"
	@test -L "$(XDG_CONFIG_HOME)/aws/config"
	@test -L "$(XDG_CONFIG_HOME)/git/config"
	@test -L "$(XDG_CONFIG_HOME)/git/ignore"
	@test -L "$(XDG_CONFIG_HOME)/ngrok/ngrok.yml"
	@test -L "$(XDG_CONFIG_HOME)/zsh/.zshrc"
	@test -L "$(XDG_CONFIG_HOME)/zsh/.zlogin"
	@test -L "$(HOME)/.zshenv"
	@test -L "$(XDG_CONFIG_HOME)/zsh/ohmyzsh/custom/themes/robbyrussell-custom.zsh-theme"
	@echo "Done"

test-asdf-tools:
	@echo "Testing asdf tool versions"
	@[[ -f "$(HOME)/.tool-versions" && -n "$(HOME)/.tool-versions" ]]
	@echo "Done"

test-aws-credentials:
	@echo "Testing AWS credentials"
	@echo $(XDG_DATA_HOME)
	@cat "$(XDG_DATA_HOME)/aws/credentials"
	@[[ -f "$(XDG_DATA_HOME)/aws/credentials" && -n "$(XDG_DATA_HOME)/aws/credentials" ]]
	@echo "Done"

test-gpg:
	@echo "Testing GPG keys"
	@[[ -d "$(XDG_DATA_HOME)/gnupg" && -O "$(XDG_DATA_HOME)/gnupg" && -r "$(XDG_DATA_HOME)/gnupg" && -w "$(XDG_DATA_HOME)/gnupg" && -x "$(XDG_DATA_HOME)/gnupg" ]]
	@echo "Done"
