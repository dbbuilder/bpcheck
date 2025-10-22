using System.Security.Claims;

namespace BloodPressureMonitor.API.Extensions;

public static class ClaimsPrincipalExtensions
{
    /// <summary>
    /// Gets the Clerk User ID from the JWT claims.
    /// Clerk stores the user ID in the 'sub' claim.
    /// </summary>
    public static string? GetClerkUserId(this ClaimsPrincipal user)
    {
        return user.FindFirst(ClaimTypes.NameIdentifier)?.Value
            ?? user.FindFirst("sub")?.Value;
    }

    /// <summary>
    /// Gets the user's email from the JWT claims.
    /// </summary>
    public static string? GetUserEmail(this ClaimsPrincipal user)
    {
        return user.FindFirst(ClaimTypes.Email)?.Value
            ?? user.FindFirst("email")?.Value;
    }

    /// <summary>
    /// Gets the user's first name from the JWT claims.
    /// </summary>
    public static string? GetFirstName(this ClaimsPrincipal user)
    {
        return user.FindFirst(ClaimTypes.GivenName)?.Value
            ?? user.FindFirst("given_name")?.Value
            ?? user.FindFirst("first_name")?.Value;
    }

    /// <summary>
    /// Gets the user's last name from the JWT claims.
    /// </summary>
    public static string? GetLastName(this ClaimsPrincipal user)
    {
        return user.FindFirst(ClaimTypes.Surname)?.Value
            ?? user.FindFirst("family_name")?.Value
            ?? user.FindFirst("last_name")?.Value;
    }

    /// <summary>
    /// Checks if the user is authenticated with Clerk.
    /// </summary>
    public static bool IsClerkAuthenticated(this ClaimsPrincipal user)
    {
        return user.Identity?.IsAuthenticated == true && !string.IsNullOrEmpty(user.GetClerkUserId());
    }
}
