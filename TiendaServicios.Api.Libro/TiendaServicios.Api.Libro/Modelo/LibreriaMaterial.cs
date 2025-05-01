using System.ComponentModel.DataAnnotations;
namespace TiendaServicios.Api.Libro.Modelo
{
    public class LibreriaMaterial
    {
        [Key] //Pk

        //Guid -> no es auto incremental, el "?" es para los nulos
        public Guid? LibreriaMaterialId { get; set; }
        public string Titulo {  get; set; }
        public DateTime? FechaPublicacion { get; set; }

        //relacion con el primer guid, es decir, union de dos tablas
        public Guid? AutorLibro { get; set; }

        //public int NewData { get; set; }
    }
}
