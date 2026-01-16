using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartTrainerPro.Api.Data;

namespace SmartTrainerPro.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PractitionersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PractitionersController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        public async Task<ActionResult<Practitioner>> CreatePractitioner(Practitioner practitioner)
        {
            _context.Practitioners.Add(practitioner);
            await _context.SaveChangesAsync();
            return Ok(practitioner);
        }

        [HttpPost("{practitionerId}/assign-patient/{userId}")]
        public async Task<IActionResult> AssignPatient(int practitionerId, int userId)
        {
            var practitioner = await _context.Practitioners.FindAsync(practitionerId);
            var user = await _context.Users.FindAsync(userId);

            if (practitioner == null || user == null) return NotFound();

            user.Practitioner = practitioner;
            await _context.SaveChangesAsync();

            return Ok();
        }

        [HttpPost("{practitionerId}/prescribe")]
        public async Task<ActionResult<Prescription>> CreatePrescription(int practitionerId, Prescription prescription)
        {
            // Verify practitioner exists (and ideally has access to user, simplified here)
            var practitioner = await _context.Practitioners.FindAsync(practitionerId);
            if (practitioner == null) return NotFound("Practitioner not found");

            var user = await _context.Users.FindAsync(prescription.UserId);
            if (user == null) return NotFound("User not found");

            _context.Prescriptions.Add(prescription);
            await _context.SaveChangesAsync();

            return Ok(prescription);
        }
    }
}
