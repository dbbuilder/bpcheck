using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BloodPressureMonitor.API.Extensions;
using System.Security.Claims;

namespace BloodPressureMonitor.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthTestController : ControllerBase
{
    /// <summary>
    /// Public endpoint to test API is running
    /// </summary>
    [HttpGet("health")]
    [AllowAnonymous]
    public IActionResult Health()
    {
        return Ok(new
        {
            status = "healthy",
            timestamp = DateTime.UtcNow,
            message = "Blood Pressure Monitor API is running"
        });
    }

    /// <summary>
    /// Protected endpoint to test Clerk authentication
    /// </summary>
    [HttpGet("me")]
    [Authorize]
    public IActionResult GetCurrentUser()
    {
        var clerkUserId = User.GetClerkUserId();
        var email = User.GetUserEmail();
        var firstName = User.GetFirstName();
        var lastName = User.GetLastName();

        // Get all claims for debugging
        var claims = User.Claims.Select(c => new
        {
            Type = c.Type,
            Value = c.Value
        }).ToList();

        return Ok(new
        {
            authenticated = true,
            clerkUserId,
            email,
            firstName,
            lastName,
            claims
        });
    }

    /// <summary>
    /// Test endpoint to verify authorization works
    /// </summary>
    [HttpGet("protected")]
    [Authorize]
    public IActionResult ProtectedEndpoint()
    {
        var clerkUserId = User.GetClerkUserId();

        return Ok(new
        {
            message = "You have accessed a protected endpoint!",
            clerkUserId,
            timestamp = DateTime.UtcNow
        });
    }
}
