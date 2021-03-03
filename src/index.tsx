import { NativeModules } from 'react-native';

type AlibcType = {
  multiply(a: number, b: number): Promise<number>;
  init(
    appkey: string,
    pid: string,
    forceH5: boolean,
  ): Promise<object>;
  login(): Promise<object>;
  isLogin(): Promise<boolean>;
  logout(): Promise<boolean>;
  getUser(): Promise<object>;
  show(
    param: object,
    type: string,
  ): Promise<object>;
};

const { Alibc } = NativeModules;

export default Alibc as AlibcType;
