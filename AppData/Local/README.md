For Windows config directory, create junction to the .config directory:

```powershell
# In the AppData\Local directory
New-Item -Type SymbolicLink -Target .config\nvim -Path nvim
New-Item -Type SymbolicLink -Target .config\clangd -Path clangd
```
