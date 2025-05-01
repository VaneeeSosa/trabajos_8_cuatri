using Microsoft.EntityFrameworkCore;
using TiendaServicios.Api.Libro.Modelo;

namespace TiendaServicios.Api.Libro.Persistencia
{
    public class ContextoLibreria:DbContext //hereda de dbcontext y hace conexion
    {

        //pasa los parametros
        public ContextoLibreria(DbContextOptions<ContextoLibreria> options):base(options) 
        { 
        
        }
        
        public DbSet<LibreriaMaterial>LibreriaMaterials { get; set; }
    }
}
