export interface LaunchContext {
  surface: string;
  fixture: string;
  page: string;
  sequence: number;
}

let currentLaunchContext: LaunchContext = {
  surface: '',
  fixture: '',
  page: 'pages/Index',
  sequence: 0
};

export function setLaunchParams(surface: string, fixture: string, page: string): void {
  currentLaunchContext = {
    surface: surface,
    fixture: fixture,
    page: page,
    sequence: currentLaunchContext.sequence + 1
  };
}

export function getLaunchParams(): LaunchContext {
  return currentLaunchContext;
}
