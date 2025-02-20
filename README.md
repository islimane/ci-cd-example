# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

# Wiki del Repositorio en Salesforce

FASE 1 - Tarifario Development - Notas y consideraciones del proyecto

## 1. Etiquetas Personalizadas (Custom Labels)

Las etiquetas personalizadas serán gestionadas mediante código. En caso de crear o modificar una etiqueta personalizada, es obligatorio notificar al equipo de desarrollo para que realicen la actualización en el entorno de desarrollo y liberen dicho cambio de manera progresiva a través de los diferentes entornos.

## 2. Objetos

- La creación y gestión de objetos es responsabilidad del equipo funcional en el entorno de desarrollo (ndev).
- Los despliegues de estos objetos se realizan mediante Change Sets.
- El equipo funcional es responsable de mantener la sincronización entre los diferentes entornos.
- Si el equipo de desarrollo añade nuevos campos, objetos u otros elementos que no estén en el repositorio, deberá informarse al equipo funcional para su correcta gestión y mantenimiento.

## 3. Flows y Validaciones (VR)

Es importante considerar los Flows y las Validaciones de Reglas (VR) en el sistema. Se debe incluir un by-pass cuando sea necesario.

## 4. Perfiles de Usuario

Es necesario conocer el perfil de los usuarios que desempeñan el rol de "Gestor de Hotel" para configurar adecuadamente la factory de estos usuarios.

## 5. Creación de Modelo de Datos en Setup Test

Para la creación del modelo de datos, se debe utilizar **TP\_SetupDataTest** tal cual. Función recomendada: `generateRatePlannerDataBundle`.

## 6. Consideraciones sobre Labels

- Las etiquetas (`Labels`) están creadas en español y no cuentan con traducción.
- Se debe coordinar con el equipo funcional para determinar cómo se gestionarán las traducciones y si deben crearse en inglés con su respectiva traducción.

## 7. GlobalConstants

Las constantes globales (`GlobalConstants`) deben mantenerse y usarse correctamente en el código.

Añadir recordTypes, datos estaticos de la org.

## 8. RatePlannerSelector

Para el uso de `RatePlannerSelector`, se debe trabajar con `RatePlannerSelector_Test` utilizando listas o mapas. Además, se debe configurar correctamente el `Set Id` de los parámetros de entrada.

## 9. Managers para Operaciones

Se deben utilizar los siguientes managers para operaciones relacionadas con planificación de tarifas:

- `RatePlannerManager`
- `RatePlannerManager_Test`

## 10. Buenas Prácticas en Código

Evitar el uso de `SaveLog` dentro de los `for` para optimizar el rendimiento del código.


