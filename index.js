const 	express = require('express'),
		app 	= express(),
		port 	= process.env['PORT'] != undefined ? process.env['PORT']:2000;

app.get('/', (req, res) => {
	console.log('We have a visitor.');
	res.status(200).json({
		status: 'ok',
		message: 'Hi. This will appear when I restart the container.',
		altered: true,
		rebooted: true
	});
});

app.listen(port, () => {
	console.log(`Listening on port: ${port}`);
});

