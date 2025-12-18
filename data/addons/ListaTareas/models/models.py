# -*- coding: utf-8 -*-

# Importamos los módulos necesarios de Odoo para definir modelos
from odoo import models, fields, api
from datetime import date

# Creamos nuestro modelo de datos principal.
# Todos los modelos de Odoo deben heredar de models.Model
class ListaTareas(models.Model):  # Buenas prácticas: nombres de clase en PascalCase (MayúsculaInicial)
    
    # Nombre técnico del modelo. Es como Odoo lo guarda internamente en la base de datos
    _name = 'lista_tareas.lista'

    # Descripción que aparece en la documentación y ayuda
    _description = 'Modelo de la lista de tareas'

    # Indica qué campo se mostrará por defecto como nombre del registro (en vistas y menús desplegables)
    _rec_name = "tarea"

    # Definimos los campos (atributos) que tendrá cada registro de este modelo:

    # Campo de tipo texto (cadena). Será el nombre de la tarea.
    tarea = fields.Char(string="Tarea")

    # Campo de tipo entero. Se usará para indicar la prioridad (ej: 1 a 100)
    prioridad = fields.Integer(string="Prioridad")

    # Campo calculado de tipo booleano. Será True si la prioridad > 10
    # compute indica el método que lo calcula
    # store=True guarda el valor en la base de datos para poder filtrar y ordenar por él
    urgente = fields.Boolean(string="Urgente", compute="_value_urgente", store=True)

    # NUEVO Campo de tipo fecha. Indica la fecha límite para completar la tarea
    fecha_limite = fields.Date(string="Fecha límite")
    # NUEVO Campo calculado de tipo booleano. Será True si la fecha límite ya pasó
    vencida = fields.Boolean(string="Vencida", compute="_compute_vencida", store=True)

    # Campo booleano normal. Será marcado si la tarea ya se realizó.
    realizada = fields.Boolean(string="Realizada")

    # Campo de relación Many2one con el modelo res.users (usuarios de Odoo)
    usuario_asignado = fields.Many2one("res.users", string="Usuario Asignado")

    # categoria es una relación Many2one con el nuevo modelo CategoriaTarea
    categoria_id = fields.Many2one('lista_tareas.categoria', string="Categoría de la Tarea", ondelete='set null')  

    # -------------------------------
    # MÉTODO COMPUTADO
    # -------------------------------
    # Este método se ejecuta cada vez que cambie el campo 'prioridad'
    @api.depends('prioridad')
    def _value_urgente(self):
        for record in self:
            # Si la prioridad es mayor que 10, se considera urgente
            record.urgente = record.prioridad > 10

    # NUEVO MÉTODO COMPUTADO
    # Este método se ejecuta cada vez que cambie el campo 'fecha_limite'
    @api.depends('fecha_limite')
    def _compute_vencida(self):
        from datetime import date
        for record in self:
            if record.fecha_limite:
                # Comparamos la fecha límite con la fecha actual
                record.vencida = record.fecha_limite < date.today()
            else:
                record.vencida = False  # Si no hay fecha límite, no está vencida    

# Crear un nuevo modelo llamado lista_tareas.categoria y relacionarlo con las tareas.
class CategoriaTarea(models.Model):
    _name = 'lista_tareas.categoria'
    _description = 'Categoría de Tarea'

    name = fields.Char(string="Nombre de la Categoría", required=True)
    descripcion = fields.Text(string="Descripción")
    # Relación Many2one en las tareas para asociarlas a una categoría.
    tareas_ids = fields.One2many('lista_tareas.lista', 'categoria_id', string="Tareas en esta Categoría")

    def name_get(self):
        result = []
        for record in self:
            name = record.name or 'Sin nombre'
            result.append((record.id, name))
        return result
