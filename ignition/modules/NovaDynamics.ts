import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const subscriptionId =
  78750991394730549220694257365894300979820205128370490572244887556655080685983n;

const NovaDynamics = buildModule("NovaDynamics", (m) => {
  const novadynamics = m.contract("NovaDynamics", [subscriptionId], {});

  return { novadynamics };
});

export default NovaDynamics;
