Este repositório contém minhas configurações pessoais (**dotfiles**), temas, ícones, cursores e papéis de parede para customização do ambiente de trabalho Linux.

## Estrutura do Repositório

```text
.
├── Config/
│   ├── cortile/         # Configuração do arranjador de janelas (tiling window manager helper)
│   ├── picom/           # Configuração de compositor para transparências e sombras
│   └── polybar/         # Barra de status personalizada
│       ├── scripts/     # Scripts auxiliares (autohide.sh, player.sh)
│       ├── autostart.sh
│       └── config.ini
├── Cursor/              # Tema de ponteiro/cursor (Qogir)
├── GTK/                 # Tema GTK (Catppuccin Blue Dark)
├── Icons/               # Pacote de ícones (Tela Circle Blue Dark)
├── Mousepad/            # Estilo do editor Mousepad (Catppuccin Blue Dark)
├── Rofi/                # Menu de aplicações/executador (Catppuccin Blue Dark)
├── Terminal/            # Esquema de cores para o terminal (Catppuccin Mocha)
└── Wallpaper/           # Papéis de parede (space.jpg)
```

---

## Temas e Estética

- **Tema GTK:** Catppuccin Blue Dark
- **Ícones:** Tela Circle Blue Dark
- **Cursor:** Qogir
- **Rofi / Mousepad:** Catppuccin Blue Dark
- **Terminal:** Catppuccin Mocha

---

## Como Aplicar As Configurações

### 1. Clocar o Repositório
```bash
git clone https://github.com/SEU-USUARIO/NOME-DO-REPOSITORIO.git
cd NOME-DO-REPOSITORIO
```

### 2. Configurações do `~/.config`
Mova ou crie links simbólicos para a sua pasta `~/.config`:

```bash
# Copiar ou criar link para o Polybar, Picom e Cortile
cp -r Config/polybar ~/.config/
cp -r Config/picom ~/.config/
cp -r Config/cortile ~/.config/
```

### 3. Instalar Temas, Ícones e Cursores
Extraia/mova os pacotes `.tar.xz` para os respectivos diretórios do usuário:

```bash
# Criar diretórios locais caso não existam
mkdir -p ~/.themes ~/.icons ~/.local/share/icons

# Extrair Cursor
tar -xf Cursor/Qogir.tar.xz -C ~/.icons/

# Extrair Ícones
tar -xf Icons/Tela-circle-blue-dark.tar.xz -C ~/.icons/

# Extrair Tema GTK
tar -xf GTK/Catppuccin-Blue-Dark.tar.xz -C ~/.themes/
```

### 4. Estilo do Mousepad
Para aplicar o tema no editor Mousepad:

```bash
mkdir -p ~/.local/share/gtksourceview-4/styles/
cp Mousepad/gtksourceview-4/styles/catppuccin-blue-dark.xml ~/.local/share/gtksourceview-4/styles/
```

### 5. Rofi
```bash
mkdir -p ~/.config/rofi
cp Rofi/catppuccin-blue-dark.rasi ~/.config/rofi/config.rasi
```

---

## Papel de Parede

O papel de parede utilizado se encontra na pasta `Wallpaper/space.jpg`.

---

## Licença

Este repositório está sob a licença [MIT](LICENSE).
