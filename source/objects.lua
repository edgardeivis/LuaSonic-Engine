objects = {
	{
		name = 'Line', 
		sprite = love.graphics.newImage('assets/sprites/editor/objects/line.png'),
		category = 'line',
		values = {
			name = {'Line #','string'},
			x1 = {0,'integer'},
			y1 = {0,'integer'},
			x2 = {128,'integer'},
			y2 = {128,'integer'}
		}
	},
	{
		name = 'Curved Line', 
		sprite = love.graphics.newImage('assets/sprites/editor/objects/line_curved.png'),
		category = 'curved_line',
		values = {
			name = {'Curve #','string'},
			x1 = {0,'integer'},
			y1 = {0,'integer'},
			x2 = {128,'integer'},
			y2 = {128,'integer'},
			iterations = {8,'slider'},
			curvature = {1,'slider'}
		}
	},	
	{
		name = 'SpawnPoint', 
		sprite = love.graphics.newImage('assets/sprites/editor/objects/spawnpoint.png'),
		category = 'object',
		values = {
			name = {'Spawnpoint','string'},
			flipped = {false,'bool'}
		}
	}
}