using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.Urls.Add("http://*:8080");

app.MapGet("/", () => new
{
    Message = "Hola desde el Backend API (Running on .NET 10 🚀)",
    Status = "Online",
    Environment = "Production-Simulated",
    Timestamp = DateTime.UtcNow
});

app.MapGet("/data", () =>
{
    var connString = Environment.GetEnvironmentVariable("SQL_CONNECTION_STRING");

    if (string.IsNullOrEmpty(connString))
        return Results.Problem("Falta la configuración de SQL");

    try
    {
        using (SqlConnection conn = new SqlConnection(connString))
        {
            conn.Open();
            var cmd = new SqlCommand("SELECT @@VERSION", conn);
            var version = cmd.ExecuteScalar()?.ToString();
            return Results.Ok(new { DatabaseStatus = "Connected", SQL_Version = version });
        }
    }
    catch (Exception ex)
    {
        return Results.Problem($"Error conectando a SQL: {ex.Message}");
    }
});

app.Run();