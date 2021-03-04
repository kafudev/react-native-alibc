import * as React from 'react';

import { StyleSheet, View, Text, Button } from 'react-native';
import Alibc from '@kafudev/react-native-alibc';

export default function App() {
  const [result, setResult] = React.useState<number | undefined>();

  React.useEffect(() => {
    Alibc.multiply(3, 7).then(setResult);
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
      <Button
        onPress={() => {
          // mm_113435089_555800032_109026900326
          Alibc.init('32486832', 'mm_113435089_555800032_109026900326').then(
            (res: any) => {
              console.log('Alibc init', res);
            }
          );
        }}
        title="初始化百川sdk"
      />
      <Button
        onPress={() => {
          Alibc.login().then((res: any) => {
            console.log('Alibc login', res);
          });
        }}
        title="授权登录"
      />
      <Button
        onPress={() => {
          Alibc.logout().then((res: any) => {
            console.log('Alibc logout', res);
          });
        }}
        title="退出登录"
      />
      <Button
        onPress={() => {
          Alibc.getUser().then((res: any) => {
            console.log('Alibc getUser', res);
          });
        }}
        title="获取用户信息"
      />
      <Button
        onPress={() => {
          Alibc.open(
            { type: 'url', url: 'http://baidu.com' },
            'H5',
            'taobao'
          ).then((res: any) => {
            console.log('Alibc open url:', res);
          });
        }}
        title="打开url"
      />
      <Button
        onPress={() => {
          Alibc.open(
            { type: 'shop', payload: '65626181' },
            'Auto',
            'taobao'
          ).then((res: any) => {
            console.log('Alibc open code:', res);
          });
        }}
        title="打开code"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
