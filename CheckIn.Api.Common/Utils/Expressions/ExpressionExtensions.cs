using System.Linq.Expressions;

namespace CheckIn.Api.Common.Utils.Expressions;

public static class ExpressionExtensions
{
    private class ParameterRebinder : ExpressionVisitor
    {
        private readonly Dictionary<ParameterExpression, ParameterExpression> _map;

        public ParameterRebinder(Dictionary<ParameterExpression, ParameterExpression> map)
        {
            this._map = map ?? new Dictionary<ParameterExpression, ParameterExpression>();
        }

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

    public static Expression<Func<T, bool>> And<T>(this Expression<Func<T, bool>> left, Expression<Func<T, bool>> right)
    {
        // Vytvorenie mapy parametrov: (druhá expression používa iný parameter ako prvá)
        var map =
            right.Parameters.Select((p, i) => new { p, replacement = left.Parameters[i] })
                .ToDictionary(x => x.p, x => x.replacement);

        var rightBody = ParameterRebinder.ReplaceParameters(map, right.Body);

        // Kombinácia tiel: (left.Body) && (right.Body)
        return Expression.Lambda<Func<T, bool>>(Expression.AndAlso(left.Body, rightBody), left.Parameters);
    }

    public static Expression<Func<T, bool>> Or<T>(this Expression<Func<T, bool>> left, Expression<Func<T, bool>> right)
    {
        var map = right.Parameters.Select((p, i) => new { p, replacement = left.Parameters[i] })
            .ToDictionary(x => x.p, x => x.replacement);

        var rightBody = ParameterRebinder.ReplaceParameters(map, right.Body);

        return Expression.Lambda<Func<T, bool>>(Expression.OrElse(left.Body, rightBody), left.Parameters);
    }
}