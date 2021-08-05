using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace primes.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PrimesController: ControllerBase
    {


        private readonly ILogger<PrimesController> _logger;

        public PrimesController(ILogger<PrimesController> logger)
        {
            _logger = logger;
        }

        [Route("{limit:int}")]
        [HttpGet()]
        public IActionResult Get(int limit)
        {
            if (limit > 100000) return BadRequest("Max Limit value is 100000");
            var primes = new List<int>();

            for (var idx =1; idx <= limit; idx++)
            {
                if (IsPrime(idx)) primes.Add(idx);
            }
            return Ok(primes);
        }

        private static bool IsPrime(int value)
        {
            for (var idx = 2; idx <=value / 2; idx++)
            {
                if ((value % idx) == 0) return false;
            }

            return true;
        }
    }
}
