# Ejercicio 1
Los diagramas fueron exportados como imágenes  y pueden ser encontrados en la carpeta images.
Los avisos de facturación fueron creados manualmente.<br>
El acceso al proyecto está ubicado en main.tf <br>

`
resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/editor"

  members = [
    "user:javioreto@gmail.com",
    "serviceAccount:steady-tape-345517@appspot.gserviceaccount.com",
    "serviceAccount:195566316688@cloudservices.gserviceaccount.com"
  ]
}
`

# Ejercicio 2
La creación de la base de datos se encuentra en el archivo main.tf.
la creación de los usuarios y bases de datos pueden manejados con las siguientes variables y pasados a traves de terraform.tfvars.

` 
variable "mysql_users" {
  type        = map(any)
  description = "(optional) describe your variable"
  default = {
    key1 = "val1"
    key2 = "val2"
  }
}

variable "databases" {
  type        = list(string)
  description = "(optional) describe your variable"
}

`

# Ejercicio 3

La tercera parte fue generada manualmente puesto que no encontré un módulo para generar la imagen desde terraform.

# Ejercicio 4

Todo el código se encuentra en app_engine.tf
De igual manera desde el directorio root se puede ejecutar terraform init, plan y apply para desplegar los recursos necesarios.
