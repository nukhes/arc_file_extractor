# Guia para Publicar no PyPI

Este guia explica como publicar o Arc File Extractor no PyPI.

## Pré-requisitos

1. **Conta no PyPI**: Crie uma conta em https://pypi.org/account/register/
2. **Conta no TestPyPI**: Crie uma conta em https://test.pypi.org/account/register/ (para testes)

## Passo a Passo

### 1. Instalar ferramentas necessárias

```bash
pip install build twine
```

### 2. Configurar versão no __init__.py

Certifique-se de que o arquivo `src/arc_file_extractor/__init__.py` tem a versão correta:

```python
__version__ = '0.1.0'
```

### 3. Construir o pacote

```bash
# Limpar builds anteriores
rm -rf dist/ build/ src/arc_file_extractor.egg-info/

# Construir o pacote
python -m build
```

### 4. Verificar o pacote

```bash
# Verificar se o pacote foi criado corretamente
twine check dist/*
```

### 5. Testar no TestPyPI (recomendado)

```bash
# Upload para TestPyPI
twine upload --repository testpypi dist/*
```

Você será solicitado a inserir seu nome de usuário e senha do TestPyPI.

Teste a instalação:
```bash
pip install --index-url https://test.pypi.org/simple/ arc-file-extractor
```

### 6. Publicar no PyPI real

```bash
# Upload para PyPI
twine upload dist/*
```

Você será solicitado a inserir seu nome de usuário e senha do PyPI.

### 7. Verificar instalação

```bash
pip install arc-file-extractor
arc --help
```

## Configuração de API Token (Recomendado)

Para maior segurança, use API tokens ao invés de senha:

1. Acesse https://pypi.org/manage/account/token/
2. Crie um novo token
3. Configure no arquivo `~/.pypirc`:

```ini
[distutils]
index-servers =
    pypi
    testpypi

[pypi]
username = __token__
password = pypi-SEU_TOKEN_AQUI

[testpypi]
repository = https://test.pypi.org/legacy/
username = __token__
password = pypi-SEU_TOKEN_TESTPYPI_AQUI
```

## Comandos Úteis

### Verificar se o nome está disponível

```bash
pip search arc-file-extractor
```

### Atualizar versão

1. Edite `src/arc_file_extractor/__init__.py`
2. Atualize a versão (ex: de 0.1.0 para 0.1.1)
3. Rebuilde e republique

### Automatizar com Makefile

Você pode usar o Makefile já existente:

```bash
# Para publicar no TestPyPI
make release-test

# Para publicar no PyPI
make release
```

## Problemas Comuns

### Nome já existe
Se o nome `arc-file-extractor` já existir, você pode:
1. Escolher outro nome no `pyproject.toml`
2. Usar um nome único como `arc-file-extractor-{seuusername}`

### Versão já existe
- Sempre incremente a versão antes de fazer upload
- PyPI não permite sobrescrever versões existentes

### Dependências não encontradas
- Certifique-se de que todas as dependências estão listadas em `pyproject.toml`
- Teste a instalação em um ambiente virtual limpo

## Manutenção

### Atualizar pacote
1. Faça suas alterações no código
2. Atualize a versão em `__init__.py`
3. Atualize `HISTORY.rst` com as mudanças
4. Rebuilde e republique

### Remover versão (não recomendado)
- PyPI permite remover versões apenas em casos extremos
- Prefira sempre criar uma nova versão corrigida

## Exemplo de Workflow Completo

```bash
# 1. Fazer alterações no código
# 2. Atualizar versão
# 3. Limpar builds anteriores
rm -rf dist/ build/ src/arc_file_extractor.egg-info/

# 4. Construir
python -m build

# 5. Verificar
twine check dist/*

# 6. Testar no TestPyPI
twine upload --repository testpypi dist/*

# 7. Testar instalação
pip install --index-url https://test.pypi.org/simple/ arc-file-extractor

# 8. Se tudo estiver OK, publicar no PyPI
twine upload dist/*
```

## Links Úteis

- [PyPI](https://pypi.org/)
- [TestPyPI](https://test.pypi.org/)
- [Guia oficial do PyPI](https://packaging.python.org/tutorials/packaging-projects/)
- [Twine documentation](https://twine.readthedocs.io/)
