<?php

require '../vendor/autoload.php';
$environmentVars = require '../environment.php';

use Slim\Container;
use Slim\App;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Message\ResponseInterface;

session_start();

$c = new Container();
$c['errorHandler'] = function ($c) {
    return function ($request, $response, $exception) use ($c) {
        return $c['response']->withStatus(500)
            ->withHeader('Content-Type', 'application/json')
            ->write(json_encode(['code' => 500, 'msg' => 'Goddamnit!']));
    };
};
$app = new App($c);
$app->post('/v1/vm', function(
    ServerRequestInterface $request,
    ResponseInterface $response) use ($environmentVars) {
    if (!$request->isXhr()) {
        throw new Exception('Not XmlHttpRequest');
    }

    if (empty($_SESSION['sandbox_dir_path'])) {
        $sandboxDirPath = sys_get_temp_dir() . DIRECTORY_SEPARATOR . uniqid();
        $srcDirPath = $sandboxDirPath . DIRECTORY_SEPARATOR . 'src';

        if (!mkdir($srcDirPath, 0777, true)) {
            throw new Exception(
                'Failed to create src dir: ' . $srcDirPath);
        }

        $_SESSION['sandbox_dir_path'] = $sandboxDirPath;
    } else {
        $sandboxDirPath = $_SESSION['sandbox_dir_path'];
        $srcDirPath = $sandboxDirPath . DIRECTORY_SEPARATOR . 'src';
    }

    $srcFilePath = $srcDirPath . DIRECTORY_SEPARATOR . 'app.rts';
    $requestBody = $request->getParsedBody();

    if (!array_key_exists('code', $requestBody)) {
        throw new Exception('No code');
    }

    if (file_put_contents($srcFilePath, $requestBody['code']) === false) {
        throw new Exception('Failed to write file: ' . $srcFilePath);
    }

    if (!chdir($sandboxDirPath)) {
        throw new Exception('Failed to set working dir:' . $sandboxDirPath);
    }

    $stdLibDirPath = escapeshellarg($environmentVars['std_lib_dir_path']);
    $output = shell_exec('realtalkc --import=' . $stdLibDirPath . ' app.rts');

    if (empty($output)) {
        $output = shell_exec('realtalkl --import=' . $stdLibDirPath
            . ' app.rte std.rtl app.rtm');

        if (empty($output)) {
            $output = shell_exec('realtalkvm build' . DIRECTORY_SEPARATOR
                . 'bin' . DIRECTORY_SEPARATOR . 'app.rte');
        }
    }

    $response = $response->withHeader('Content-Type', 'application/json');
    return $response->write(json_encode(['output' => $output]));
});
$app->run();
