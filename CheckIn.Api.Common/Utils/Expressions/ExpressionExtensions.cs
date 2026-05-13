/*
------------------------------------------------
This file was made by Gemini
------------------------------------------------
*/

using System.Linq.Expressions;

namespace CheckIn.Api.Common.Utils.Expressions;

/// <summary>
/// Utility class providing extension methods to combine LINQ expressions dynamically.
/// </summary>
public static class ExpressionExtensions
{
    /// <summary>
    /// Helper class that rebinds parameters of one expression to match another.
    /// This is necessary because combining two separate Lambda bodies requires them to share the same ParameterExpression instance.
    /// </summary>
    private class ParameterRebinder : ExpressionVisitor
    {
        private readonly Dictionary<ParameterExpression, ParameterExpression> _map;

        public ParameterRebinder(Dictionary<ParameterExpression, ParameterExpression> map)
        {
            this._map = map ?? new Dictionary<ParameterExpression, ParameterExpression>();
        }

        /// <summary>
        /// Replaces parameters in an expression based on the provided mapping.
        /// </summary>
        public static Expression ReplaceParameters(Dictionary<ParameterExpression, ParameterExpression> map,
            Expression exp)
        {
            return new ParameterRebinder(map).Visit(exp);
        }

        protected override Expression VisitParameter(ParameterExpression p)
        {
            if (_map.TryGetValue(p, out var replacement))
            {
                return replacement;
            }

            return base.VisitParameter(p);
        }
    }

    /// <summary>
    /// Combines two expressions using a logical AND (&&) operation.
    /// </summary>
    public static Expression<Func<T, bool>> And<T>(this Expression<Func<T, bool>> left, Expression<Func<T, bool>> right)
    {
        // Create a map between the parameters of the right expression and the left expression
        var map =
            right.Parameters.Select((p, i) => new { p, replacement = left.Parameters[i] })
                .ToDictionary(x => x.p, x => x.replacement);

        // Rebind parameters in the body of the right expression to match the left one
        var rightBody = ParameterRebinder.ReplaceParameters(map, right.Body);

        // Combine the bodies using logical AND and create a new lambda
        return Expression.Lambda<Func<T, bool>>(Expression.AndAlso(left.Body, rightBody), left.Parameters);
    }

    /// <summary>
    /// Combines two expressions using a logical OR (||) operation.
    /// </summary>
    public static Expression<Func<T, bool>> Or<T>(this Expression<Func<T, bool>> left, Expression<Func<T, bool>> right)
    {
        // Create a map between the parameters of the right expression and the left expression
        var map = right.Parameters.Select((p, i) => new { p, replacement = left.Parameters[i] })
            .ToDictionary(x => x.p, x => x.replacement);

        // Rebind parameters in the body of the right expression to match the left one
        var rightBody = ParameterRebinder.ReplaceParameters(map, right.Body);

        // Combine the bodies using logical OR and create a new lambda
        return Expression.Lambda<Func<T, bool>>(Expression.OrElse(left.Body, rightBody), left.Parameters);
    }
}