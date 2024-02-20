# Blog Application Setup and installations

## Steps to build application code

1. Make changes to the source code in ``src/``.

2. Create build folder

```
npm run build
```

3. Replace the build folder in ``resources/storage_account/webfiles/``

4. Copy the index.html file from  ``resources/storage_account/webfiles/build/`` to ``resources/azure_function/react/webapp/``.

5. Run the terraform apply action.
